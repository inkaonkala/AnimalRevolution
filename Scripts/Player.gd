extends CharacterBody2D

@export var speed := 200.0

var can_move := true

func _physics_process(delta: float) -> void:
	
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_direction := Vector2.ZERO

	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_direction = input_direction.normalized()

	velocity = input_direction * speed
	move_and_slide()
