extends Area2D

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

signal emotion_hadler

@export var cat_name := "John"
@export var floorspawn_index := 0
@export var therapyspaw_i := 0
@export var species := "cat"

@onready var speak_bubble = $Label

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
	add_to_group("animals")
	DayCycle.new_day.connect(cat_new_day)
	body_entered.connect(cat_activated)
	speak_bubble.visible = false
	
func cat_new_day(daynmb: int) -> void:
	on_new_day()
	
func on_new_day() -> void:
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

func cat_talk(text: String) -> void:
		speak_bubble.text = text
		speak_bubble.visible = true
		await  get_tree().create_timer(1.5). timeout
		speak_bubble.visible = false

func cat_activated(body: Node) -> void:
	if body.name != "Player":
		return
		
	if state == State.LOST:
		await first_meeting()
		return
	
	#	state = State.HAPPY
	#	GameState.cat_found = true
	#	await cat_talk("Why not? I'll joi the revolution")
	#	print("Cat found!")
	#	return
	
	if state == State.HUNGRY and not GameState.tagging_unlocked:
		GameState.tagging_unlocked = true
		state = State.HAPPY
		emotion_hadler.emit()
		hunger_timer = 0
		await cat_talk("Use this TAG to mark humans good wnought to eat")
		return
		
	match state:
		State.HAPPY:
			await cat_talk("Why not to eat humans? They are simple creatures anyway.")
		State.WORKING:
			await cat_talk("Let's make some meat")
		State.NEEDS_THERAPY:
			await cat_talk("I should have not looked them in the eyes ...")
		State.IN_THERAPY:
			await cat_talk("Were else can we get our protein and vitamins?")
		_:
			await cat_talk("I am hungry and boored")
			
func first_meeting() -> void:
	has_joined = true
	GameState.cat_found = true
	state = State.NEUTRAL
	emotion_hadler.emit()
	
	await cat_talk("Why not? I'll join the revolution")
	
	print("Cat found: ", cat_name)
	if is_on_3thfloor():
		activate_spotly()
	else:			
		move_to_catfloor()
		
func is_on_3thfloor() -> bool:
	var parent = get_parent()
	return parent != null and parent.name == "ThirdFloor"
	
func activate_spotly() -> void:
	state = State.NEUTRAL
	emotion_hadler.emit()
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
