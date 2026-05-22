extends Area2D

@export var baby_picup_Scene: PackedScene
@export var baby_texture: Texture2D

@onready var talk_bubble = $Label
@onready var baby_spawn_point = $babySpawnPoint


var has_talked1	 := false
var baby_exists := false

func _ready() -> void:
	body_entered.connect(hamster_touched1)
	
func hamster_touched1(body: Node) -> void:
	if body.name != "Player":
		return
	
	if not has_talked1:	
		has_talked1 = true
		await make_hamster_talk("Hello! Nice to meet ya!")
		await make_hamster_talk("My name is Joanna!")
		await make_hamster_talk("Come, and help me at the rooftop!")
		move_to_rooftop()
		return
		
	if baby_exists:
		await make_hamster_talk("My baby's there to help you!")
		return
	
	await make_hamster_talk("Use my baby to dig the soil!")
	spawn_baby()
	
			
func make_hamster_talk(text: String) ->void:
	talk_bubble.text = text
	talk_bubble.visible = true
	
	await get_tree().create_timer(1.5).timeout
	talk_bubble.visible = false
	
#func move_to_rooftop() -> void:
#	var rooftop = get_node(rooftop_path)
#	var spawn = get_node(rooftop_spawn)
#	
#	get_parent().remove_child(self)
#	rooftop.add_child(self)
#	
#	global_position = spawn.global_position

func move_to_rooftop() -> void:
	var main = get_tree().current_scene
	var rooftop = main.get_node("FloorContainer/Rooftop")
	var spawn = main.get_node("FloorContainer/Rooftop/HamsterSpawnPoint2")
	
	get_parent().remove_child(self)
	rooftop.add_child(self)
	
	global_position = spawn.global_position

func spawn_baby() -> void:
	if baby_picup_Scene == null:
		print("No baby_pickup_scene")
		return
	var baby = baby_picup_Scene.instantiate()
	
	baby.item_id = "hamsterbaby"
	baby.amount = 1
	baby.item_tex = baby_texture
	
	get_parent().add_child(baby)
	baby.global_position = baby_spawn_point.global_position
	
	baby.collected.connect(on_baby_collected)
	baby_exists = true

func on_baby_collected(item_id: String) -> void:
		if item_id == "hamsterbaby":
			baby_exists = false
