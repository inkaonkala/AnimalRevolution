extends Area2D

enum State {
	LOST,
	FOUND,
	HAPPY,
	SAD,
	ANGRY,
	NEUTRAL
}

signal emotion_hadler

@export var dog_name := "Tilly"
@export var floorspawn_index := 0
@export var species := "dog"

@onready var speak_bubble = $Label

var state := State.LOST
var has_joined := false

func _ready() -> void:
	add_to_group("animals")
	speak_bubble.visible = false
