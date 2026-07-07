extends Area2D

enum State
{
	LOST,
	WORKING,
	SAD,
	NEUTRAL,
	HAPPY,
	HUNGRY
}

signal emotion_hadler

@export var species := "rodent"
@export var rodent_name := "BunBun"
@export var intro_line: Array[String] = [
	"Hello!",
	"I can help you on the rooftop!"
]

#@export var roof_path: NodePath
#@export var roof_spawn_path: NodePath
@export var spawn_index := 0

@onready var talk_bubble = $Label

var state := State.LOST
var has_talked := false
var days_without_food := 0
var plants_watered := 0

func _ready() -> void:
	add_to_group("animals")
	body_entered.connect(on_body_entered)
	DayCycle.new_day.connect(on_new_day)
	talk_bubble.visible = false
	
func on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	if state == State.LOST:
		await first_meeting()
	else:
		await talk()
		
	print("Rodent found!")
	
func first_meeting() -> void:
	if has_talked:
		return
	has_talked = true
	
	for line in intro_line:
		await say_this(line)
	
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
		
func say_this(text: String) -> void:
	talk_bubble.text = text
	talk_bubble.visible = true
	await get_tree().create_timer(1.5).timeout
	talk_bubble.visible = false
		
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
	emotion_hadler.emit()
		
			
func on_new_day(day_nmb: int) -> void:
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
		
	emotion_hadler.emit()
	
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

func update_sidebar() -> void:
	var main = get_tree().current_scene
	if main.has_node("CanvasSideBar"):
		main.get_node("CanvasSideBar").update_animal_emotions()
