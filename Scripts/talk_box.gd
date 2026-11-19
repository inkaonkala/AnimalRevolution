extends CanvasLayer

#USE SIGNAL HERE TO CONNECT 
@onready var panel = $PanelContainer
@onready var portrait = $PanelContainer/HBoxContainer/Picture
@onready var dialogue_text = $PanelContainer/HBoxContainer/Dialogue

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()

	DialogueManager.dialogue_requested.connect(show_dialogue)
	DialogueManager.dialogue_closed.connect(hide_dialogue)

func show_dialogue(
	text: String,
	image: Texture2D
) -> void:
	dialogue_text.text = text
	portrait.texture = image
	panel.show()

func hide_dialogue() -> void:
	panel.hide()
