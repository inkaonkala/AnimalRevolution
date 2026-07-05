extends CharacterBody2D

@export var speed := 200.0
@onready var attack_area = $AttackArea
@onready var animated_sprite = $Sprite2D

var can_move := true

var attack_power := 1
var hp := 10
var enemies_in_attack_area: Array = []

func _ready() -> void:
	add_to_group("player")
	animated_sprite.play()
	attack_area.body_entered.connect(attackarea_entered)
	attack_area.body_exited.connect(attackarea_exited)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_direction := Vector2.ZERO

	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_direction = input_direction.normalized()

	if input_direction.x > 0:
		animated_sprite.flip_h = true
	elif input_direction.x < 0:
		animated_sprite.flip_h = false
	velocity = input_direction * speed
	move_and_slide()
	
func take_damage(amount: int) -> void:
	hp -= amount
	print("Player hp:", hp)

	if hp <= 0:
		print("PlayerDefeted!")

func attackarea_entered(body: Node) -> void:
	if body == self:
		return
		
	if body.has_method("take_damage"):
		print("Can damage: ", body.name)
		enemies_in_attack_area.append(body)

func attackarea_exited(body: Node) -> void:
	if body in enemies_in_attack_area:
		enemies_in_attack_area.erase(body)

func attack() -> void:
	print("Player attacks!")

	if enemies_in_attack_area.size() <= 0:
		print("No ENEMY!")
		return

	var target = enemies_in_attack_area[0]
	print("There's an enemy! ")

	if target.has_method("take_damage"):
		target.take_damage(attack_power)
