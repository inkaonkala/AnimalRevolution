extends AnimalBase


enum State {
	LOST,
	ON_SPOT,
	WORKING,
	SAD,
	HAPPY,
	TIRED
}

@export var turtle_name := "Tilda"

var state := State.LOST


func _ready() -> void:
	species = "turtle"
	intro_lines = [
	"Hello, small revolution creature.",
	"I am trained in emotional damage.",
	"Meet me on the cat floor."
	]
	super._ready()
	DayCycle.new_day.connect(on_new_day)

func first_meeting() -> void:
	await super.first_meeting()
	move_to_catfloor()
	emit_emotion_changed()

func talk() -> void:
	match state:
		State.HAPPY:
			await say_this("The cats are healing. Slowly. Dramatically.")
		State.SAD:
			await say_this("You could heal me with flowers .. ..")
		State.WORKING:
			await say_this("Please wait. A cat is processing its feelings.")
		State.TIRED:
			await say_this("I need a quiet corner and something pretty")
		_:
			await say_this("I live on the cat floor now.")


func move_to_catfloor() -> void:
	var main = get_tree().current_scene
	var cat_floor = main.get_node("FloorContainer/ThirdFloor")
	var spawn_point = cat_floor.get_node("SpawnPoints/TurtleSpawn")

	get_parent().remove_child(self)
	cat_floor.add_child(self)

	global_position = spawn_point.global_position
	state = State.ON_SPOT


func on_new_day(_day_number: int) -> void:
	hide_talk_bubble()
	if state == State.ON_SPOT or state == State.HAPPY:
		do_therapy()


func do_therapy() -> void:
	print(turtle_name, " soothing cat feelings")

func get_emotion_value() -> int:
	match state:
		State.HAPPY:
			return 1
		State.SAD, State.TIRED:
			return -1
		_:
			return 0
