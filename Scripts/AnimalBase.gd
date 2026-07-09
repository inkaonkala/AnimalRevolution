extends Area2D
class_name AnimalBase

signal emotion_hadler

@export var species := "animal"
@export var intro_lines: Array[String] = []

@onready var talk_bubble: Label = $Label

var player_near := false
var is_talking := false
var has_talked := false

func _ready() -> void:
	add_to_group("animals")
	talk_bubble.visible = false
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exit)
	
func _process(_delta: float) -> void:
	if not player_near or is_talking:
		return
	if Input.is_action_just_pressed("interact"):
		if should_first_meet():
			await first_meeting()
		else:
			await talk()
			

func on_body_enter(body: Node) -> void:
	if body.name == "Player":
		player_near = true

func on_body_exit(body: Node) -> void:
	if body.name == "Player":
		player_near = false
		hide_talk_bubble()

func hide_talk_bubble() -> void:
	talk_bubble.visible = false
	is_talking = false
	
func say_this(text: String) -> void:
	if is_talking:
		return
	is_talking = true
	talk_bubble.text = text
	talk_bubble.visible = true
	
	await get_tree().create_timer(2).timeout
	
	talk_bubble.visible = false
	is_talking = false
	
func should_first_meet() -> bool:
	return not has_talked
	
func first_meeting() -> void:
	has_talked = true
	
	for line in intro_lines:
		await say_this(line)

func talk() -> void:
	await say_this("... ...")

func update_sidebar() -> void:
	var main = get_tree().current_scene

	if main.has_node("CanvasSideBar"):
		main.get_node("CanvasSideBar").update_animal_emotions()

func emit_emotion_changed() -> void:
	emotion_hadler.emit()
	call_deferred("update_sidebar")

func get_emotion_value() -> int:
	return 0
	
func unlock_object(node_path: String) -> void:
	var main = get_tree().current_scene

	if main.has_node(node_path):
		main.get_node(node_path).visible = true
