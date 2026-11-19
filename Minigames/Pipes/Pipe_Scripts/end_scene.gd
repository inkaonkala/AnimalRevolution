extends Node2D

@export var succes_txt: Texture2D
@export var fail_txt: Texture2D
@onready var result_button: Button = $CanvasLayer/Button

func _ready() -> void:
	if GameResult.success:
		result_button.icon = succes_txt
	else:
		result_button.icon = fail_txt


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/open_scene.tscn")
