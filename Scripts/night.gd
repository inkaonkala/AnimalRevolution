extends Control

signal continue_pressed

@onready var report_label = $ReportLabel
@onready var continue_button = $ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(on_continue_pressed)

func update_report() -> void:
	report_label.text = create_report_text()

func on_continue_pressed() -> void:
	continue_pressed.emit()

func create_report_text() -> String:
	var text := ""
	text += "Night report\n\n"
	text += "Meat produced: +" + str(GameState.butschered_lastnight) + "\n"
	text += "Total meat: " + str(GameState.meat) + "\n"
	return text
