extends Area2D

@export var box_name := "Storage"
@export var allowed_items: Array[String] = []

@onready var box_menu = $CanvasLayer/BoxMenu
@onready var box_label = $CanvasLayer/BoxMenu/Label
@onready var item_list = $CanvasLayer/BoxMenu/ItemList
@onready var close_button = $CanvasLayer/BoxMenu/CloseButton

var player_near := false
var stored_items := {}
var box_open := false

func _ready() -> void:
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exit)
	close_button.pressed.connect(close_box)
	box_menu.visible = false
	
func _process(_delta: float) -> void:
	if box_open:
		return
	if player_near and Input.is_action_just_pressed("interact"):
		open_box()
		
func on_body_enter(body: Node) -> void:
	if body.name == "Player":
		player_near = true

	
func	 on_body_exit(body: Node) -> void:
	if body.name == "Player":
		player_near = false

func close_box() -> void:
	var main = get_tree().current_scene
	
	box_open = false
	box_menu.visible = false
	main.player.can_move = true
	
func refresh_menu() -> void:
	for child in item_list.get_children():
		child.queue_free()
	var main = get_tree().current_scene
	
	for item_id in main.invi_order:
		var amount = main.inventory.get(item_id, 0)
		if amount <= 0:
			continue
		if not can_accept(item_id):
			continue
		
		var button := Button.new()
		#new line
		var id_for_button = item_id
		
		
		button.text = item_id + ": " + str(amount) + " → put 1"
#		button.pressed.connect(func(): put_one_item(item_id))
		button.pressed.connect(func(): put_one_item(id_for_button))
		item_list.add_child(button)

func open_box() -> void:
	if box_open:
		return
	var main = get_tree().current_scene
	
	box_open = true 
	box_label.text = box_name
	box_menu.visible = true
	main.player.can_move = false
	refresh_menu()
	
func can_accept(item_id: String) -> bool:
		if allowed_items.is_empty():
			return true
		return item_id in allowed_items
		
func put_one_item(item_id: String) -> void:
		print("HERE HREHRHE EHRHERH EHRHERHEHR EHR HRH")
		var main = get_tree().current_scene
		if not main.remove_item(item_id, 1):
			return
		if not stored_items.has(item_id):
			stored_items[item_id] = 0
		stored_items[item_id] += 1
		print(box_name, " contains: ", stored_items)
		refresh_menu()
	
