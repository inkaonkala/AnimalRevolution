extends AnimalBase

enum State
{
	LOST,
	HAPPY,
	NEUTRAL,
	SAD,
	WORKING,
	HUNGRY,
	NEEDS_THERAPY,
	IN_THERAPY
}


@export var cat_name := "John"
@export var floorspawn_index := 0
@export var therapyspaw_i := 0

var state := State.LOST
var has_joined := false

var work_nights := 0
var hunger_timer := 0
var happy_nights_left := 0
var therapy_days_left := 0

var meat_per_neutral_cat := 1
var meat_per_happy_cat := 2
var max_work_nights := 6

func _ready() -> void:
	species = "cat"
	intro_lines = [ "I want to rule my world",
		"I'll join your revolution",
		"Found me on floor 3"
	]
	super._ready()
	DayCycle.new_day.connect(on_new_day)

func should_first_meet() -> bool:
	return state == State.LOST
	
func first_meeting() -> void:
	await super.first_meeting()
	has_joined = true
	GameState.cat_found = true
	state = State.NEUTRAL
	emit_emotion_changed()
	
	if is_on_3thfloor():
		activate_spotly()
	else:
		move_to_catfloor()

func talk() -> void:
	if state == State.HUNGRY and not GameState.tagging_unlocked:
		GameState.tagging_unlocked = true
		state = State.HAPPY
		hunger_timer = 0
		emit_emotion_changed()
		await say_this("Use this TAG to mark humans good enough to eat")
		return
		
	match state:
		State.HAPPY:
			await say_this("Why not to eat humans? They are simple creatures anyway.")
		State.WORKING:
			await say_this("Let's make some meat")
		State.NEEDS_THERAPY:
			await say_this("I should have not looked them in the eyes ...")
		State.IN_THERAPY:
			await say_this("Where else can we get our protein and vitamins?")
		State.HUNGRY:
			await say_this("I am hungry.")
		_:
			await say_this("I am hungry and bored")


func on_new_day(_day_number: int) -> void:
	hide_talk_bubble()
	if state == State.LOST:
		return

	if state == State.IN_THERAPY:
		therapy_days_left -= 1
		if therapy_days_left <= 0:
			state = State.NEUTRAL
			emotion_hadler.emit()
			move_to_catfloor()
		return

	if state == State.SAD or state == State.NEEDS_THERAPY:
		move_to_threapy()
		return

	try_eating()

	if state == State.HAPPY:
		butcher(meat_per_happy_cat)
		happy_nights_left -= 1

		if happy_nights_left <= 0:
			state = State.NEUTRAL
			emotion_hadler.emit()

	elif state == State.NEUTRAL:
		butcher(meat_per_neutral_cat)

	work_nights += 1

	if work_nights >= max_work_nights:
		state = State.SAD
		emotion_hadler.emit()
		move_to_threapy()

func is_on_3thfloor() -> bool:
	var parent = get_parent()
	return parent != null and parent.name == "ThirdFloor"
	
func activate_spotly() -> void:
	state = State.NEUTRAL
	emit_emotion_changed()
	print(cat_name, " on CAT floor found")
			
func move_to_catfloor() -> void:
	var main = get_tree().current_scene
	var cat_floor = main.get_node("FloorContainer/ThirdFloor")
	var spawn_points = cat_floor.get_node("SpawnPoints/CatSpawns").get_children()
	
	if floorspawn_index >= spawn_points.size():
		print("CAT: No room to spawn!! ", cat_name)
		return
	var spawn = spawn_points[floorspawn_index]
	
	get_parent().remove_child(self)
	cat_floor.add_child(self)
	
	global_position = spawn.global_position

func move_to_threapy() -> void:
	var main = get_tree().current_scene
	var cat_floor = main.get_node("FloorContainer/ThirdFloor")
	var therapy_spawns = cat_floor.get_node("SpawnPoints/TherapySpawns").get_children()

	if therapyspaw_i >= therapy_spawns.size():
		print("Therapy full")
		return

	var spawn = therapy_spawns[therapyspaw_i]
	global_position = spawn.global_position

	state = State.IN_THERAPY
	emotion_hadler.emit()
	therapy_days_left = 2
	work_nights = 0


func become_hungry() ->void:
	state = State.HUNGRY
	emotion_hadler.emit()
	#GameState.tagging_unlocked = true
	print("Cat's hungry!")
	
func butcher(amount: int) -> void:
#	GameState.meat += amount
#	GameState.butschered_lastnight += amount
#	print(cat_name, " produced ", amount, " meat.")
	print(cat_name, " can butcher now ", amount, " meat.")
	
func need_therapy() -> void:
	state = State.NEEDS_THERAPY
	emotion_hadler.emit()
	print("Cat's in need of threrapy")
	
func try_eating() -> void:
	if not GameState.tagging_unlocked:
		hunger_timer += 1
		if hunger_timer >= 3:
			become_hungry()
			return
			
	if GameState.meat <= 0:
		return

	GameState.meat -= 1
	state = State.HAPPY
	emotion_hadler.emit()
	happy_nights_left = 2
	print(cat_name, " ate meat and became happy.")

func get_emotion_value() -> int:
	match state:
		State.HAPPY:
			return 1
		State.SAD, State.NEEDS_THERAPY, State.IN_THERAPY, State.HUNGRY:
			return -1
		State.NEUTRAL, State.WORKING:
			return 0
		_:
			return 0
			
func is_unlocked() -> bool:
	return state != State.LOST
