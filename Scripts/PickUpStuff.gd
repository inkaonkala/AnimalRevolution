extends Area2D

@export var item_id := "seed"
@export var amount := 1
@export var item_tex: Texture2D

@onready var sprite = $Sprite2D

signal collected(item_id: String)

func _ready() -> void:
	if item_tex:
		sprite.texture = item_tex
	body_entered.connect(add_item_to_items)
	
func add_item_to_items(body: Node) -> void:
	if body.name == "Player":
		var main = get_tree().current_scene
		main.add_item(item_id, amount)
		collected.emit(item_id)
		queue_free()

func update_texture() -> void:
	if sprite != null and item_tex != null:
		sprite.texture = item_tex
