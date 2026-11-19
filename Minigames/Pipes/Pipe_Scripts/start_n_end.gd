extends Node2D

enum PipeType {
	START,
	END1,
	END2,
	END3
}


@export var start_texture: Texture2D
@export var end1_texture: Texture2D
@export var end2_texture: Texture2D
@export var end3_texture: Texture2D
@export var pipe_type: PipeType

@onready var sprite: Sprite2D = $Sprite2D

var grid_pos: Vector2i
var rotation_step := 0

const CELL_SIZE = 32

func _ready() -> void:
	sprite.position = Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
	

func get_connections() -> Array[Vector2i]:
	var connections: Array[Vector2i] = []

	match pipe_type:
		PipeType.START:
			connections = [
				Vector2i.RIGHT
			]

		PipeType.END1:
			connections = [
				Vector2i.LEFT
			]

		PipeType.END2:
			connections = [
				Vector2i.UP,
				Vector2i.LEFT
			]

		PipeType.END3:
			connections = [
				Vector2i.RIGHT,
				Vector2i.UP,
				Vector2i.DOWN
			]

	return rotate_connections(connections)
	
func rotate_connections(connections: Array[Vector2i]) -> Array[Vector2i]:
	var rotated: Array[Vector2i] = []

	for connection in connections:
		var new_direction := connection

		for i in range(rotation_step):
			new_direction = Vector2i(
				-new_direction.y,
				new_direction.x
			)

		rotated.append(new_direction)

	return rotated


func set_direction(direction: Vector2i) -> void:
	var step := 0

	match direction:
		Vector2i.RIGHT:
			step = 0
		Vector2i.DOWN:
			step = 1
		Vector2i.LEFT:
			step = 2
		Vector2i.UP:
			step = 3

	# END1 starts facing LEFT instead of RIGHT
	if pipe_type == PipeType.END1:
		step = (step + 2) % 4

	set_rotation_step(step)
	
func update_sprite() -> void:
	match pipe_type:
		PipeType.START:
			sprite.texture = start_texture

		PipeType.END1:
			sprite.texture = end1_texture

		PipeType.END2:
			sprite.texture = end2_texture

		PipeType.END3:
			sprite.texture = end3_texture

func set_rotation_step(step: int) -> void:
	rotation_step = step
	sprite.rotation_degrees = rotation_step * 90
