extends Area2D

@export var box_name := "Storage"
@export var box_type := "storage"
@export var allowed_items: Array[String] = []
@export var starts_unlocked := true

@onready var box_canvas = $CanvasLayer
@onready var box_menu = $CanvasLayer/BoxMenu
@onready var box_label = $CanvasLayer/BoxMenu/Label
@onready var item_list = $CanvasLayer/BoxMenu/ItemList
@onready var close_button = $CanvasLayer/BoxMenu/CloseButton
@onready var box_sprite = $Sprite2D

var player_near := false
var stored_items := {}
var box_open := false

func _ready() -> void:

	add_to_group("item_boxes")
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exit)
	close_button.pressed.connect(close_box)
	box_canvas.visible = false
	box_menu.visible = false
	
	print(name, " starts_unlocked: ", starts_unlocked)
	
	box_sprite.visible = starts_unlocked
	monitorable = starts_unlocked
	monitoring = starts_unlocked
	
	
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
	box_canvas.visible = false
	main.player.can_move = true
	
	
func refresh_menu() -> void:
	for child in item_list.get_children():
		child.queue_free()
		
	var main = get_tree().current_scene
	
	#create the LABEL for invenotry
	var inv_title := Label.new()
	inv_title.text = "Inventory"
	item_list.add_child(inv_title)
	
	for item_id in main.invi_order:
		var amount = main.inventory.get(item_id, 0)
		if amount <= 0:
			continue
		if not can_accept(item_id):
			continue
		
		#buttons to take items
		var button := Button.new()
		var id_for_button = item_id
		button.text = item_id + ": " + str(amount) + " → put 1"
#		button.pressed.connect(func(): put_one_item(item_id))
		button.pressed.connect(func(): put_one_item(id_for_button))
		item_list.add_child(button)
		
	#ITEM BOX
	var box_title := Label.new()
	box_title.text = "Box"
	item_list.add_child(box_title)
	
	for item_id in stored_items.keys():
		var amount = stored_items.get(item_id, 0)
		if amount <= 0:
			continue
			
		var button := Button.new()
		var id_for_button = item_id 
		button.text = item_id + ": " + str(amount) + "-> take 1"
		button.pressed.connect(func(): take_one_item(id_for_button))
		item_list.add_child(button)
			

func open_box() -> void:
	if box_open:
		return
	var main = get_tree().current_scene
	
	box_open = true 
	box_label.text = box_name
	box_canvas.visible = true
	box_menu.visible = true
	main.player.can_move = false
	refresh_menu()
	
func can_accept(item_id: String) -> bool:
		if allowed_items.is_empty():
			return true
		return item_id in allowed_items
		
func put_one_item(item_id: String) -> void:
		var main = get_tree().current_scene
		if not main.remove_item(item_id, 1):
			return
		if not stored_items.has(item_id):
			stored_items[item_id] = 0
		stored_items[item_id] += 1
		print(box_name, " contains: ", stored_items)
		refresh_menu()
		
func take_one_item(item_id: String) -> void:
	if stored_items.get(item_id, 0) <= 0:
		return
	stored_items[item_id] -= 1
	if stored_items[item_id] <= 0:
		stored_items.erase(item_id)
	
	var main = get_tree().current_scene
	main.add_item(item_id, 1)
	refresh_menu()
	
func consume_one_item(item_id: String) -> bool:
		if stored_items.get(item_id, 0) <= 0:
			return false
		stored_items[item_id] -= 1
		
		if stored_items[item_id] <= 0:
			stored_items.erase(item_id)
		print(box_name, "consumed 1 ", item_id, ". Left: ", stored_items)
		return true
	
func unlock_box() -> void:
	box_sprite.visible = true
	monitoring = true
	monitorable = true	
