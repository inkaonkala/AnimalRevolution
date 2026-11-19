extends Node2D

@onready var sprite: AnimatedSprite2D = $rat

var grid_pos
const CELL_SIZE = 32

func setup_enemies(pos: Vector2i) -> void:
	grid_pos = pos
	position = Vector2(
		grid_pos.x * 32,
		grid_pos.y * 32
	)
	sprite.play()
