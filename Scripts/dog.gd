extends Area2D

enum State {
	LOST,
	FOUND,
	HAPPY,
	SAD,
	ANGRY,
	NEUTRAL
}

signal emotion_hadler

@export var dog_name := "Tilly"
@export var spawn_index := 0
@export var species := "dog"
@export var intro_line: Array[String] = [
	"Ohoy! I want to join the revolution too!"
]

@onready var speak_bubble = $Label

var state := State.LOST
var player_near := false
var has_joined := false
var is_talking := false
var has_talked := false
var days_without_food := 0


func _ready() -> void:
	add_to_group("animals")
	speak_bubble.visible = false
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exit)
	DayCycle.new_day.connect(on_new_day)

func _process(_delta: float) -> void:
	if not player_near or is_talking:
		return

	if Input.is_action_just_pressed("interact"):
		if state == State.LOST:
			await first_meeting()
		else:
			await talk()

func on_body_exit(body: Node) -> void:
	if body.name == "Player":
		player_near = false
		speak_bubble.visible = false
			
		
func on_body_enter(body: Node) -> void:
	if body.name == "Player":
		player_near = true	
	
#func on_body_enter(body: Node) -> void:
#	if body.name != "Player":
#		return
#	if state == State.LOST:
#		await first_meeting()
#	else:
#		await talk()
		
func first_meeting() -> void:
	if has_talked:
		return
	has_talked = true
	for line in intro_line:
		await say_this(line)

func talk() -> void:
	match state:
		State.HAPPY:
			await say_this("Dogs rule!")
		State.SAD:
			await say_this("I want BEEF")

		_:
			await say_this("I am boored")
		
func say_this(text: String) -> void:
	if is_talking:
		return
	is_talking = true
	
	speak_bubble.text = text
	speak_bubble.visible = true
	await get_tree().create_timer(1.5).timeout
	speak_bubble.visible = false
	is_talking = false
		
func on_new_day(_day_number: int) -> void:
	speak_bubble.visible = false
