extends Area2D

enum Stage {
	EMPTY,
	DUG,
	SEEDED,
	WATERED,
	GROWING,
	READY
}

@export var empty_tex: Texture2D
@export var dug_tex: Texture2D

@export var available_crops: Array[CropData]

@onready var sprite: Sprite2D = $Sprite2D

var stage := Stage.EMPTY
var player_near := false

var current_crop: CropData = null
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

	stage = Stage.DUG
	update_image()


func try_interact() -> void:
	if stage == Stage.DUG:
		try_plant_seed()
	elif stage == Stage.SEEDED or stage == Stage.GROWING or stage == Stage.WATERED:
		try_water()
	elif stage == Stage.READY:
		try_harvest()


func try_plant_seed() -> void:
	var main = get_tree().current_scene

	for crop in available_crops:
		if crop == null:
			continue

		if main.has_item(crop.seed_id):
			main.remove_item(crop.seed_id)

			current_crop = crop
			stage = Stage.SEEDED
			growth_stage = 0
			is_watered = false

			update_image()
			return

	print("No usable seed!")

func try_water() -> void:
	if current_crop == null:
		print("No crop planted!")
		return

	var main = get_tree().current_scene

	if not main.has_item("bottle"):
		print("No bottle!")
		return

	if is_watered:
		print("Already watered")
		return

	var fountains = get_tree().get_nodes_in_group("fountain")
	if fountains.is_empty():
		print("No fountain found!")
		return

	var fountain = fountains[0]

	if not fountain.use_water():
		return

	is_watered = true

	if stage == Stage.SEEDED:
		stage = Stage.WATERED

	update_image()


func on_new_day(_day_numb: int) -> void:
	if current_crop == null:
		return

	if stage != Stage.GROWING and stage != Stage.WATERED:
		return

	if not is_watered:
		update_image()
		return

	growth_stage += 1
	is_watered = false

	if growth_stage >= current_crop.growth_texs.size():
		stage = Stage.READY
	else:
		stage = Stage.GROWING

	update_image()


func try_harvest() -> void:
	var main = get_tree().current_scene

	if current_crop == null:
		print("No crop data found!")
		return

	main.add_item(current_crop.crop_id, current_crop.harvest_amount)
	main.add_item(current_crop.seed_id, current_crop.seed_return_amount)

	current_crop = null
	stage = Stage.EMPTY
	growth_stage = 0
	is_watered = false

	update_image()


func update_image() -> void:
	if stage == Stage.EMPTY:
		sprite.texture = empty_tex
	elif stage == Stage.DUG:
		sprite.texture = dug_tex
	elif current_crop == null:
		sprite.texture = empty_tex
	elif stage == Stage.SEEDED:
		sprite.texture = current_crop.seed_tex
	elif stage == Stage.WATERED:
		sprite.texture = current_crop.watered_tex
	elif stage == Stage.GROWING:
		update_growing_image()
	elif stage == Stage.READY:
		sprite.texture = current_crop.ready_tex


func update_growing_image() -> void:
	if current_crop == null:
		return

	if growth_stage < 1:
		growth_stage = 1

	var index := growth_stage - 1

	if is_watered:
		if index < current_crop.wet_growth_texs.size():
			sprite.texture = current_crop.wet_growth_texs[index]
	else:
		if index < current_crop.growth_texs.size():
			sprite.texture = current_crop.growth_texs[index]


# RODENT WATERING
func water_by_rodent() -> bool:
	if current_crop == null:
		return false

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
