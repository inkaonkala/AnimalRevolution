extends Area2D

@export var water_per_bottle := 5

@onready var hint_label = $Label

var player_near := false
var current_water := 0


func _ready() -> void:
	add_to_group("fountain")
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exit)
	hint_label.visible = false


func on_body_enter(body: Node) -> void:
	if body.name == "Player":
		player_near = true
		hint_label.text = "Press E to fill bottle"
		hint_label.visible = true


func on_body_exit(body: Node) -> void:
	if body.name == "Player":
		player_near = false
		hint_label.visible = false


func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("interact"):
		fill_bottles()


func fill_bottles() -> void:
	var main = get_tree().current_scene

	if not main.has_item("bottle"):
		print("No bottle to fill!")
		return

	current_water = main.inventory.get("bottle", 0) * water_per_bottle
	print("Water filled: ", current_water)


func use_water() -> bool:
	if current_water <= 0:
		print("Bottle is empty!")
		return false

	current_water -= 1
	print("Water left: ", current_water)
	return true
