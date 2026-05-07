extends Area2D

enum Stage
{
	EMPTY,
	DUG,
	SEEDED,
	WATERED,
	GROWING,
	READY
}

@export var empty_tex: Texture2D
@export var dug_tex: Texture2D
@export var seed_tex: Texture2D
@export var watered_tex: Texture2D

@onready var sprite = $Sprite2D

var stage := Stage.EMPTY
var player_near := false
var seed_planted := ""

func _ready() -> void:
	update_image()
	body_entered.connect(body_enter)
	body_exited.connect(body_exit)
	
func _process(_delta: float) -> void:
	if not player_near:
		return
	if Input.is_action_just_pressed("attack"):
		try_dig()
	if Input.is_action_just_pressed("interact"):
			try_interact()
	
func body_enter(body: Node) -> void:
	if body.name == "Player":
		player_near = true
		
func body_exit(body: Node) -> void:
	if body.name == "Player":
		player_near = false

func try_dig() -> void:
	var main = get_tree().current_scene
	
	if stage != Stage.EMPTY:
		return
	if main.hamsterbaby <= 0:
		print("Need hasterbaby to dig!")
		return
	
	main.hamsterbaby -= 1
	main.update_inventory_ui()
	
	stage = Stage.DUG
	update_image()

func try_interact() -> void:
		if stage == Stage.DUG:
			try_plant_seed()
		elif stage == Stage.SEEDED:
			try_water()

func try_plant_seed() -> void:
	var main = get_tree().current_scene
	if main.seeds <= 0:
		print("No seed!")
		return
		
	main.seeds -= 1
	main.update_inventory_ui()
	
	seed_planted = "seed"
	stage = Stage.SEEDED
	update_image()
	
func try_water() ->void:
	var main = get_tree().current_scene
	
	if main.bottle <= 0:
		print("No water!")
		return
		
	stage = Stage.WATERED
	update_image()
	
func update_image() -> void:
	if stage == Stage.EMPTY:
		sprite.texture = empty_tex
	elif stage == Stage.DUG:
		sprite.texture = dug_tex
	elif stage == Stage.SEEDED:
		sprite.texture = seed_tex
	elif stage == Stage.WATERED:
		sprite.texture = watered_tex
	
