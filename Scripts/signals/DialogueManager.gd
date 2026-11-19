extends Node

signal dialogue_requested(text: String, portrait: Texture2D)
signal dialogue_closed
signal next_line

var dialogue_active := false
var waiting_for_input := false
var can_advance := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func speak(text: String, portrait: Texture2D) -> void:
	dialogue_active = true
	waiting_for_input = false
	can_advance = false

	get_tree().paused = true
	dialogue_requested.emit(text, portrait)

	# Wait until the E that started this line is released
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	waiting_for_input = true
	can_advance = true

	await next_line

	waiting_for_input = false
	can_advance = false


func _input(event: InputEvent) -> void:
	if not dialogue_active:
		return

	if event.is_action_pressed("interact") and not event.is_echo():
		get_viewport().set_input_as_handled()

		if waiting_for_input and can_advance:
			waiting_for_input = false
			next_line.emit()


func close() -> void:
	if not dialogue_active:
		return

	dialogue_active = false
	waiting_for_input = false
	can_advance = false

	dialogue_closed.emit()

	# Wait until E is released before unpausing
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	get_tree().paused = false
