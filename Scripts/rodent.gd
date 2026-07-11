extends AnimalBase

enum State
{
	LOST,
	WORKING,
	SAD,
	NEUTRAL,
	HAPPY,
	HUNGRY
}

@export var rodent_name := "BunBun"
@export var spawn_index := 0

var state := State.LOST
var days_without_food := 0
var plants_watered := 0

func _ready() -> void:
	species = "rodent"
	intro_lines = [
		"Hello!",
		"For some food,",
		"I can help you on the rooftop!"
	]
	super._ready()
	DayCycle.new_day.connect(on_new_day)

func should_first_meet() -> bool:
	return state == State.LOST
	
func first_meeting() -> void:
	await super.first_meeting()
	move_to_rooftop()
	
func talk() -> void:
	match state:
		State.HAPPY:
			await say_this("The rooftop smells like carrots and revolution!")
		State.SAD:
			await say_this("I an NOT happy")
		State.WORKING:
			await say_this("Shouldn't you be sleeping?")
		_:
			await say_this("I live on the rooftop now")
		
func move_to_rooftop() -> void:
	var main = get_tree().current_scene
	var rooftop = main.get_node("FloorContainer/Rooftop")
	var spawn_points = rooftop.get_node("SpawnPoints").get_children()
	
	if spawn_index >= spawn_points.size():
		print("No place to spawn for the", rodent_name)
		return
		
	var spawn = spawn_points[spawn_index]
				
	get_parent().remove_child(self)
	rooftop.add_child(self)
		
	global_position = spawn.global_position
	state = State.NEUTRAL
	emit_emotion_changed()
	
	var food_box = main.get_node("FloorContainer/Rooftop/RodentFoodBox")
	food_box.unlock_box()
			
func on_new_day(day_nmb: int) -> void:
	hide_talk_bubble()
	if state == State.LOST:
		return
	eat_from_box()
	
	if state == State.NEUTRAL or state == State.HAPPY:
		work_at_night()


func work_at_night() -> void:
	plants_watered = get_water_amount()
	var watered_count := water(plants_watered)
	
	print(rodent_name, " watered ", watered_count, " plant(s).")
	
func water(amount: int) -> int:
	var main = get_tree().current_scene
	var rooftop = main.get_node("FloorContainer/Rooftop/plantAreas")
	
	var watered := 0
	
	for plant in rooftop.get_children():
		if watered >= amount:
			break
		if plant.has_method("water_by_rodent"):
			if plant.water_by_rodent():
				watered += 1
	
	return watered
		

func get_water_amount() -> int:
	match state:
		State.HAPPY:
			return 2
		State.SAD:
			return 0
		State.NEUTRAL:
			return 1
		_:
			return 0
			

func find_rodent_foodbox() -> Node:
	#var main = get_tree().current_scene
	var boxes = get_tree().get_nodes_in_group("item_boxes")
	
	for box in boxes:
		if box.box_type == "rodent_food":
			return box
	return null
			
func eat_from_box() -> void:
	var food_box = find_rodent_foodbox()
	if food_box != null and food_box.consume_one_item("carrot"):
		state = State.HAPPY
		days_without_food = 0
		call_deferred("update_sidebar")
		print(rodent_name, " ate carrot. Is happy!")
	else:
		days_without_food += 1
		
		if days_without_food >= 3:
			state = State.SAD
			call_deferred("update_sidebar")
		else:
			state = State.NEUTRAL
		
	emit_emotion_changed()
	
func get_emotion_value() -> int:
	match state:
		State.HAPPY:
			return 1
		State.SAD, State.HUNGRY:
			return -1
		State.NEUTRAL, State.WORKING:
			return 0
		_:
			return 0

func is_unlocked() -> bool:
	return state != State.LOST
