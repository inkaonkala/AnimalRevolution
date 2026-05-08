extends CharacterBody2D

enum State
{
	ROAMING,
	SLEEPING,
	DEFEDING,
	CAPTURED
}

@export var normal_tex: Texture2D
@export var sleeping_tex: Texture2D
@export var captured_tex: Texture2D

@export var speed := 35.0
@export var hp := 5
@export var attack_power := 1

@onready var sprite = $Sprite2D
@onready var attack_area = $AttackArea
@onready var interact_area = $InteractArea

var captured := false
var state := State.ROAMING
var move_dir := Vector2.ZERO
var change_dir_timer := 0.0
var player_in_attack_area := false
var player = null

func _ready() -> void:
	randomize()
	choose_new_dir()
	update_by_time()
	
func _physics_process(delta: float) -> void:
	if captured:
		return
	
	update_by_time()
	
	if state == State.ROAMING:
		roam(delta)
	elif state == State.SLEEPING:
		velocity = Vector2.ZERO
	
	move_and_slide()
		
func update_by_time() -> void:
	#check what ToD and make sleep, now just roam
	if captured:
		state = State.CAPTURED
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
	print("Human hp: ", hp)
		
	if hp <= 0:
		become_captured()
	else:
		defend()
			
func defend() -> void:
	state = State.DEFEDING
	print("Human defends!")
			
func become_captured() -> void:
	captured = true
	state = State.CAPTURED
	velocity = Vector2.ZERO
	update_image()
	print("Human captured!")
		
func update_image() -> void:
	if state == State.CAPTURED and captured_tex:
		sprite.texture = captured_tex
	elif state == State.SLEEPING and sleeping_tex:
		sprite.texture = sleeping_tex
	elif normal_tex:
		sprite.texture = normal_tex
			
