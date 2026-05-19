extends Node2D

@onready var player = $Player
@onready var floor_container = $FloorContainer
@onready var current_floor = $FloorContainer/FifthFloor
#NIGHT
@onready var night = $NightManager/Night

@onready var side_bar = $CanvasSideBar/SideBarUI
@onready var elevator_popup = $CanvasHints/ElevatorPop
@onready var hint_e = $CanvasHints/HintE

#inventory
@onready var inv_zero = $CanvasSideBar/SideBarUI/InveZero
@onready var inv_1 = $CanvasSideBar/SideBarUI/Inve1
@onready var inv_2 = $CanvasSideBar/SideBarUI/Inve2
@onready var inv_3 = $CanvasSideBar/SideBarUI/Inve3
@onready var inv_4 = $CanvasSideBar/SideBarUI/Inve4

var spawn_from := "first"
var near_elevator := false

#NIGHT
var  night_open := false

#inventory
var inventory := {}
var invi_order := []

@onready var inv_slots := [
	$CanvasSideBar/SideBarUI/TextureRect0,
	$CanvasSideBar/SideBarUI/TextureRect1,
	$CanvasSideBar/SideBarUI/TextureRect2,
	$CanvasSideBar/SideBarUI/TextureRect3,
	$CanvasSideBar/SideBarUI/TextureRect4
]

var item_icons := {
	"seed": preload("res://Assets/Collectables/ballB.png"),
	"bottle": preload("res://Assets/Collectables/bottle.png"),
	"hamsterbaby": preload("res://Assets/Collectables/hamsterbaby.png"),
	"crop": preload("res://Assets/Plants/carrot.png")
}

func _ready() -> void:
	spawn_player()
	update_inventory_ui()
	setup_elevator(current_floor)
	hint_e.visible = false
	elevator_popup.visible = false
	#set NIGHT off
	night.visible = false
	night.continue_pressed.connect(close_night_report)
	#ACTIVATE FLOORS!
	set_floor_active($FloorContainer/Rooftop, false)
	set_floor_active($FloorContainer/FourthFloor, false)
	set_floor_active($FloorContainer/FifthFloor, true)
	set_floor_active($FloorContainer/ThirdFloor, false)

func _process(delta: float) -> void:
	if night_open:
		if Input.is_action_just_pressed("interact"):
			close_night_report()
		return
		
	if near_elevator and Input.is_action_just_pressed("interact"):
		open_elevator_popup()

func spawn_player() -> void:
	var spawn_point: Marker2D

	if spawn_from == "elevator":
		spawn_point = current_floor.get_node("ElevatorSpawn")
	else:
		spawn_point = current_floor.get_node("FirstSpawn")

	player.global_position = spawn_point.global_position

#NIGHT maaging
func show_night_report() -> void:
	night.visible = true
	night_open = true
	player.can_move = false
	
	if night.has_method("update_report"):
		night.update_report()

func close_night_report() -> void:
	night.visible = false
	night_open = false
	player.can_move = true

#inventory

func update_inventory_ui() -> void:
	for slot in inv_slots:
		slot.texture = null
		slot.visible = false
		
	for i in range(min(invi_order.size(), inv_slots.size())):
		var item_id = invi_order[i]
		inv_slots[i].visible = true
		inv_slots[i].texture = item_icons.get(item_id, null)
#		inv_zero.text = "Seeds: " + str(inventory.get("seed", 0))
#		inv_1.text = "Bottle: " + str(inventory.get("bottle", 0))
#		inv_2.text = "Baby: " + str(inventory.get("hamsterbaby", 0))
#		inv_3.text = "Crops: " + str(inventory.get("crop", 0))
#		inv_4.text = "empty"
		
func add_item(item_id: String, amount: int) -> void:
	if not inventory.has(item_id):
		inventory[item_id] = 0
	if inventory[item_id] <= 0 and item_id not in invi_order:
			invi_order.append(item_id)
	inventory[item_id] += amount
	update_inventory_ui()
	
func remove_item(item_id: String, amount: int = 1) -> bool:
	if inventory.get(item_id, 0) < amount:
		return false

	inventory[item_id] -= amount

	if inventory[item_id] <= 0:
		inventory.erase(item_id)
		invi_order.erase(item_id)

	update_inventory_ui()
	return true

func has_item(item_id: String, amount: int = 1) -> bool:
	return inventory.get(item_id, 0) >= amount


#invi end

#Elevator setup
func setup_elevator(floor_node: Node) -> void:
	var elevator_area = floor_node.get_node("AreaElevator")
	
	if not elevator_area.body_entered.is_connected(enter_elevator):
		elevator_area.body_entered.connect(enter_elevator)
	if not elevator_area.body_exited.is_connected(exit_elevator):
		elevator_area.body_exited.connect(exit_elevator)

func enter_elevator(body: Node) -> void:
	if body == player:
		near_elevator = true
		hint_e.visible = true
	
func exit_elevator(body: Node) -> void:
	if body == player:
		near_elevator = false
		hint_e.visible = false
		

func open_elevator_popup() -> void:
	hint_e.visible = false
	elevator_popup.visible = true
	player.can_move = false


func _on_roof_top_pressed() -> void:
	change_floor("Rooftop")

func _on_floor_five_pressed() -> void:
	change_floor("FifthFloor")
	
func _on_floor_four_pressed() -> void:
	change_floor("FourthFloor")
	
func _on_floor_three_pressed() -> void:
	change_floor("ThirdFloor") # Replace with function body.


#these are to make the collision work only on the floor the player is
	
func change_floor(floor_name: String) -> void:
	elevator_popup.visible = false
	
	current_floor.visible = false
	current_floor.process_mode = Node.PROCESS_MODE_DISABLED
	set_floor_active(current_floor, false)
	
	current_floor = floor_container.get_node(floor_name)
	
	current_floor.visible = true
	current_floor.process_mode = Node.PROCESS_MODE_INHERIT
	set_floor_active(current_floor, true)
	
	spawn_from = "elevator"
	spawn_player()
	
	near_elevator = false
	setup_elevator(current_floor)
	
	player.can_move = true
	
#func set_floor_collision(node: Node, enabled: bool) -> void:
#	for child in node.get_children():
#		if child is CollisionShape2D:
#			child.disabled = not enabled
#		elif child is CollisionPolygon2D:
#			child.disabled = not enabled
#		elif child is StaticBody2D or child is Area2D:
#			set_floor_collision(child, enabled)
#		else:
#			set_floor_collision(child, enabled)

func set_floor_active(node: Node, enabled: bool) -> void:
	if node is CollisionShape2D:
		node.disabled = not enabled
	elif node is CollisionPolygon2D:
		node.disabled = not enabled
	elif node is TileMapLayer:
		node.collision_enabled = enabled
	elif node is TileMap:
		node.collision_enabled = enabled
	elif node is Area2D:
		node.monitoring = enabled
		node.monitorable= enabled

	for child in node.get_children():
		set_floor_active(child, enabled)
			
