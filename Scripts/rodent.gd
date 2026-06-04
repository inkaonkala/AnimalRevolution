extends Area2D

enum State
{
	LOST,
	ON_ROOF,
	WORKING,
	SAD,
	HAPPY
}

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
var plants_watered := 0

func _ready() -> void:
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
	state = State.ON_ROOF
		
			
func on_new_day(day_nmb: int) -> void:
	if state == State.ON_ROOF or state == State.HAPPY:
		work_at_night()


func work_at_night() -> void:
	plants_watered = get_water_amount()
	print(rodent_name, " watered ", plants_watered, " plant(s).")


func get_water_amount() -> int:
	match state:
		State.HAPPY:
			return 2
		State.SAD:
			return 0
		_:
			return 1
