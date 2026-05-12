extends CharacterBody2D

enum State
{
	ROAMING,
	SLEEPING,
	DEFEDING,
	CAPTURED,
	TAGGED
}

@export var normal_tex: Texture2D
@export var sleeping_tex: Texture2D
@export var captured_tex: Texture2D
@export var tagged_tex: Texture2D

@export var speed := 35.0
@export var hp := 5
@export var attack_power := 1

@onready var sprite = $Sprite2D
@onready var attack_area = $AttackArea
@onready var interact_area = $InteractArea
@onready var collision_shape = $CollisionShape2D

var captured := false
var attacked := false
var tagged := false
var player_near := false

var state := State.ROAMING
var move_dir := Vector2.ZERO
var change_dir_timer := 0.0
var player_in_attack_area := false
var attack_cooldown := 0.0

var player = null

func _ready() -> void:
	randomize()
	attack_area.body_entered.connect(attackarea_entered)
	attack_area.body_exited.connect(attackarea_exited)
	interact_area.body_entered.connect(interact_entered)
	interact_area.body_exited.connect(interact_exited)
	choose_new_dir()
	update_by_time()

func _process(_delta: float) -> void:
	if captured and player_near and Input.is_action_just_pressed("interact"):
		tag_for_factory()
	
func _physics_process(delta: float) -> void:
	if captured:
		return
		
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	update_by_time()
	
	if state == State.ROAMING:
		roam(delta)
	elif state == State.SLEEPING:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
func attackarea_entered(body: Node)-> void:
	if body.is_in_group("player"):
		player_in_attack_area = true
		player = body
		
func attackarea_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_attack_area = false
		player = null
		
func update_by_time() -> void:
	#check what ToD and make sleep, now just roam
	if captured:
		state = State.CAPTURED
	elif attacked and player_in_attack_area and player != null:
		attack_player()
		return	
	else:
		state = State.ROAMING
		
	update_image()
		
func roam(delta: float)-> void:
		change_dir_timer -= delta
		
		if change_dir_timer <= 0:
			choose_new_dir()
		velocity = move_dir * speed

func choose_new_dir() -> void:
	var direcs = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN,
		Vector2.ZERO
	]
	
	move_dir = direcs.pick_random()
	change_dir_timer = randf_range(1.0, 3.0)
	
func take_damage(amount: int) -> void:
	if captured:
		return
	hp -= amount
	attacked = true
	print("Human hp: ", hp)
	
	if hp <= 0:
		become_captured()
	else:
		defend()
		
			
func defend() -> void:
	state = State.DEFEDING
	print("Human defends!")
	
func attack_player() -> void:
	if attack_cooldown > 0:
		return
	state =  State.DEFEDING
	velocity = Vector2.ZERO
	print("HUMAN attacks player!!")
	
	if player.has_method("take_damage"):
		player.take_damage(attack_power)
	attack_cooldown = 1.0
			
func become_captured() -> void:
	captured = true
	state = State.CAPTURED
	velocity = Vector2.ZERO
	update_image()
	collision_shape.disabled = true
	print("Human captured!")
	
func interact_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_near = true

func interact_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_near = false
		
func tag_for_factory() -> void:
	if tagged:
		return

	tagged = true
	state = State.TAGGED
	update_image()
	collision_shape.disabled = true
	
	print("Human tagged for factory!")
		
func update_image() -> void:
	if state == State.CAPTURED and captured_tex:
		sprite.texture = captured_tex
	elif state == State.SLEEPING and sleeping_tex:
		sprite.texture = sleeping_tex
	elif state == State.TAGGED and tagged_tex:
		sprite.texture = tagged_tex
	elif normal_tex:
		sprite.texture = normal_tex
			
