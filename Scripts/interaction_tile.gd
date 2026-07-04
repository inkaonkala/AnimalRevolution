extends Area2D

class_name InteractionTile

enum ResetMode {
	ONE_TIME,
	DAILY,
	SET_DAY,
	TIMER
}

@export var pickup_scene: PackedScene

@export var loot_table: Array[Dictionary] = [
	{
		"item_id": "carrot_seed",
		"weight": 40,
		"texture": preload("res://Assets/Collectables/ballB.png")
	},
	{
		"item_id": "flower1_seed",
		"weight": 10,
		"texture": preload("res://Assets/Collectables/kukka1seed.png")
	},
	{
		"item_id": "flower2_seed",
		"weight": 10,
		"texture": preload("res://Assets/Collectables/kukka2seed.png")
	},
	{
		"item_id": "eggplant_seed",
		"weight": 20,
		"texture": preload("res://Assets/Collectables/munaseed.png")
	}
]

@export var reset_mode := ResetMode.ONE_TIME
@export var set_day := 3
@export var cooldown_seconds := 10.0

@onready var spawn_point: Marker2D = $ItemSpawn
@onready var timer: Timer = $Timer

var player_near := false
var active := true
var spawned_item: Node = null

func _ready() -> void:
	body_entered.connect(on_enter_bod)
	body_exited.connect(on_exit_bod)
	timer.timeout.connect(on_timerout)
	DayCycle.new_day.connect(on_new_day)

func _process(_delta: float) -> void:
	if player_near and active and Input.is_action_just_pressed("interact"):
		interact()

func on_enter_bod(body: Node) -> void:
	if body.name == "Player":
		player_near = true

func on_exit_bod(body: Node) -> void:
	if body.name == "Player":
		player_near = false

func on_timerout() -> void:
	active = true
	
func interact() -> void:
	if pickup_scene == null:
		print("PICUP SCENE NOT FOUND!")
		return
	if loot_table.is_empty():
		print("loot not set")
		return
	if spawned_item != null and is_instance_valid(spawned_item):
		return
	
	var loot := loot_ROLL()
	spawn_pickup(loot)
	deactivate_lootspot()

func loot_ROLL() -> Dictionary:
	print("Choosing the loot ...")
	
	var total_kg := 0
	for entry in loot_table:
		total_kg += int(entry.get("weight", 1))
	
	var roll := randi_range(1, total_kg)
	var current := 0
	
	for entry in loot_table:
		current += int(entry.get("weight", 1))
		if roll <= current:
			return entry
		
	return loot_table[0]
		
func spawn_pickup(loot: Dictionary) -> void:
	print("this is the loot: ", loot)

	spawned_item = pickup_scene.instantiate()
	get_parent().add_child(spawned_item)
	spawned_item.global_position = spawn_point.global_position
	
	spawned_item.item_id = loot.get("item_id", "seed")
	spawned_item.item_tex = loot.get("texture", null)

	if spawned_item.has_method("update_texture"):
		spawned_item.update_texture()
	
func deactivate_lootspot() -> void:
	print("lootspot OFF")
	active = false
	
	match reset_mode:
		ResetMode.ONE_TIME:
			pass
		ResetMode.DAILY:
			pass
		ResetMode.SET_DAY:
			pass
		ResetMode.TIMER:
			timer.start(cooldown_seconds)
	
func on_new_day(day_nmb: int) -> void:
	if reset_mode == ResetMode.DAILY:
		active = true
	if reset_mode == ResetMode.SET_DAY and day_nmb == set_day:
		active = true
	
