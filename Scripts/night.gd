extends Node2D

@onready var report_label = $ReportLabel

func _ready() -> void:
	report_label.text = create_report_text()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://Scenes/main.tscn")

func create_report_text() -> String:
	var text := ""
	text += "Night report\n\n"
	text += "Meat produced: +" + str(GameState.butschered_lastnight) + "\n"
	text += "Total meat: " + str(GameState.meat) + "\n"
	text += "\nPress E to continue"
	return text
