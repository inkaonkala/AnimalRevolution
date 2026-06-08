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
@export var ready_tex: Texture2D

@export var growth_texs: Array[Texture2D]
@export var wet_growth_texs: Array[Texture2D]

@onready var sprite = $Sprite2D

var stage := Stage.EMPTY
var player_near := false
var seed_planted := ""

var growth_stage := 0
var is_watered := false

func _ready() -> void:
	update_image()
	body_entered.connect(body_enter)
	body_exited.connect(body_exit)
	DayCycle.new_day.connect(on_new_day)
	
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
	if not main.has_item("hamsterbaby"):
		print("Need hamsterbaby to dig!")
		return

	main.remove_item("hamsterbaby")
#	main.update_inventory_ui()
	
	stage = Stage.DUG
	update_image()

func try_interact() -> void:
		if stage == Stage.DUG:
			try_plant_seed()
		elif stage == Stage.SEEDED or stage == Stage.GROWING:
			try_water()
		elif stage == Stage.READY:
			try_harvest()

func try_plant_seed() -> void:
	var main = get_tree().current_scene
	if not main.has_item("seed"):
		print("No seed!")
		return

	main.remove_item("seed")
#	main.update_inventory_ui()
	
	seed_planted = "carrot"
	stage = Stage.SEEDED
	growth_stage = 0
	is_watered = false
	update_image()
	
func try_water() ->void:
	var main = get_tree().current_scene
	
	if not main.has_item("bottle"):
		print("No water!")
		return
		
	if is_watered:
		print("Already watered")
		return
		
	is_watered = true
		
	if stage == Stage.SEEDED:
		stage = Stage.WATERED
	elif stage == Stage.GROWING:
		stage = Stage.GROWING
	update_image()

func on_new_day(day_numb: int) -> void:
	if stage != Stage.GROWING and stage != Stage.WATERED:
		return
	if not is_watered:
		update_image()
		return
	
	growth_stage += 1
	is_watered = false
	
	if growth_stage >= growth_texs.size():
		stage = Stage.READY
	else:
		stage = Stage.GROWING
	
	update_image()
	
func try_harvest() -> void:
	var main = get_tree().current_scene
	
	main.add_item("carrot", 1)
	main.add_item("seed", 1)
	
	seed_planted = ""
	stage = Stage.EMPTY
	growth_stage = 0
	is_watered = false
	
	update_image()

func update_image() -> void:
	if stage == Stage.EMPTY:
		sprite.texture = empty_tex
	elif stage == Stage.DUG:
		sprite.texture = dug_tex
	elif stage == Stage.SEEDED:
		sprite.texture = seed_tex
	elif stage == Stage.GROWING:
		update_growing_image()
	elif stage == Stage.WATERED:
		sprite.texture = watered_tex
	elif stage == Stage.READY:
		sprite.texture = ready_tex
		
func update_growing_image() -> void:
	if growth_stage < 1:
		growth_stage = 1
	
	var index := growth_stage - 1
	
	if is_watered:
		if index < wet_growth_texs.size():
			sprite.texture = wet_growth_texs[index]
	else:
		if index < growth_texs.size():
			sprite.texture = growth_texs[index]
	
#RODENT WATERIG
func water_by_rodent() -> bool:
	if is_watered:
		return false

	if stage == Stage.SEEDED:
		is_watered = true
		stage = Stage.WATERED
		update_image()
		return true

	if stage == Stage.GROWING:
		is_watered = true
		update_image()
		return true

	return false
