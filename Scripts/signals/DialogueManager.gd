extends Node

signal dialogue_requested(
	text: String,
	portrait: Texture2D
)

signal dialogue_closed

var dialog_active := false
var waiting_for_input := false

func speak(text: String, portrait: Texture2D) -> void:
	dialog_active = true
	waiting_for_input = false
	dialogue_requested.emit(text, portrait)
	
	#little timer to forget the e was pressed to meet the animal
	await get_tree().process_frame
	
	waiting_for_input = true
	
	while dialog_active and waiting_for_input:
		await get_tree().process_frame

func unhandeled_input(event: InputEvent) -> void:
	if not dialog_active or not waiting_for_input:
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		waiting_for_input = false
		get_viewport().set_input_as_handled()

func close() -> void:
	dialog_active = false
	waiting_for_input = false
	dialogue_closed.emit()
