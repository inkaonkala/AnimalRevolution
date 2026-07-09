extends AnimalBase

@export var baby_picup_Scene: PackedScene
@export var baby_texture: Texture2D

@onready var baby_spawn_point = $babySpawnPoint
@onready var anim: AnimatedSprite2D = $Sprite2D

var baby_exists := false

func _ready() -> void:
	species = "hamster"
	intro_lines = [
		"Hello! Nice to meet ya!",
		"My name is Yolanda!",
		"Come, and help me at the rooftop!"
	]
	super._ready()

func first_meeting() -> void:
	await super.first_meeting()
	move_to_rooftop()

func talk() -> void:
	if baby_exists:
		await say_this("My baby's there to help you!")
		return

	await say_this("Use my baby to dig the soil!")
	await spawn_baby()

func move_to_rooftop() -> void:
	var main = get_tree().current_scene
	var rooftop = main.get_node("FloorContainer/Rooftop")
	var spawn = main.get_node("FloorContainer/Rooftop/HamsterSpawnPoint2")
	
	get_parent().remove_child(self)
	rooftop.add_child(self)
	
	global_position = spawn.global_position
	unlock_object("FloorContainer/Rooftop/RodentFoodBox")
	
func spawn_baby() -> void:
	if baby_picup_Scene == null:
		print("No baby_pickup_scene")
		return
		
	anim.play("birth")
	await anim.animation_finished
	anim.play("default")
	var baby = baby_picup_Scene.instantiate()
	
	baby.item_id = "hamsterbaby"
	baby.amount = 1
	baby.item_tex = baby_texture
	
	get_parent().add_child(baby)
	baby.global_position = baby_spawn_point.global_position
	
	if baby.has_method("update_texture"):
		baby.update_texture()
	
	baby.collected.connect(on_baby_collected)
	baby_exists = true

func on_baby_collected(item_id: String) -> void:
		if item_id == "hamsterbaby":
			baby_exists = false
