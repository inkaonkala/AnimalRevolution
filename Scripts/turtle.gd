extends Area2D

enum State {
	LOST,
	ON_SPOT,
	WORKING,
	SAD,
	HAPPY,
	TIRED
}

@export var turtle_name := "Tilda"

@export var intro_lines: Array[String] = [
	"Hello, small revolution creature.",
	"I am trained in emotional damage.",
	"Take me to the cat floor."
]

@onready var talk_bubble = $Label

var state := State.LOST
var has_talked := false


func _ready() -> void:
	body_entered.connect(on_body_enter)
	DayCycle.new_day.connect(on_new_day)
	talk_bubble.visible = false


func on_body_enter(body: Node) -> void:
	if body.name != "Player":
		return

	if state == State.LOST:
		await first_meeting()
	else:
		await talk()


func first_meeting() -> void:
	if has_talked:
		return

	has_talked = true

	for line in intro_lines:
		await say_this(line)

	move_to_catfloor()


func talk() -> void:
	match state:
		State.HAPPY:
			await say_this("The cats are healing. Slowly. Dramatically.")
		State.SAD:
			await say_this("Even therapists need soup sometimes.")
		State.WORKING:
			await say_this("Please wait. A cat is processing its feelings.")
		State.TIRED:
			await say_this("I need a quiet corner and exactly one lettuce leaf.")
		_:
			await say_this("I live on the cat floor now.")


func say_this(text: String) -> void:
	talk_bubble.text = text
	talk_bubble.visible = true
	await get_tree().create_timer(1.8).timeout
	talk_bubble.visible = false


func move_to_catfloor() -> void:
	var main = get_tree().current_scene
	var cat_floor = main.get_node("FloorContainer/ThirdFloor")
	var spawn_point = cat_floor.get_node("SpawnPoints/TurtleSpawn")

	get_parent().remove_child(self)
	cat_floor.add_child(self)

	global_position = spawn_point.global_position
	state = State.ON_SPOT


func on_new_day(_day_number: int) -> void:
	if state == State.ON_SPOT or state == State.HAPPY:
		do_therapy()


func do_therapy() -> void:
	print(turtle_name, " soothing cat feelings")
