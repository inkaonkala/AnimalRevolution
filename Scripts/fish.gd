extends AnimalBase

enum State {
	LOST,
	FOUND,
	HAPPY,
	SAD,
	NEUTRAL,
}

@export var fish_name := "Bubsy"
@export var spawn_index := 0
@export var aquarium_tex: Texture2D
@export var fish_text: Texture2D

@onready var minigame_dialog: ConfirmationDialog = $MiniGameDialog
@onready var fish_sprite: Sprite2D = $Sprite2D

var state := State.LOST
var has_joined := false
var days_without_food := 0
var has_triggered_minigame := false

func _ready() -> void:
	species = "fish"
	intro_lines = [
			"Build me a bigger home!"
		]
		
	super._ready()
	DayCycle.new_day.connect(on_new_day)
	minigame_dialog.confirmed.connect(minigame_triggered)
	
	if aquarium_tex != null:
		fish_sprite.texture = aquarium_tex

func pipe_check() -> bool:
	var main := get_tree().current_scene
	if main == null:
		return false
	if not ("inventory" in main):
		push_warning("Fish game could not find inventory")
		return false
	return main.inventory.get("pipe", 0) >= 10

func first_meeting() -> void:
	#await super.first_meeting()
	if has_joined:
		await talk()
		return
	if not pipe_check():
		await say_this("With 10 pipes, I could help you and our fish community!")
		return
		
	await say_this("Ypu have enough pipes! Want to help FISH?")
	
	minigame_dialog.dialog_text = \
		"Use 10 pipes to play the build_aquarium_game?"
	minigame_dialog.popup_centered()
	#state = State.NEUTRAL
	#emit_emotion_changed()
	
func talk() -> void:
	match state:
		State.HAPPY:
			await say_this("Finally I have space to swim!")
		State.SAD:
			await say_this("I need more water")
		_:
			await say_this("Blub blub")
		
func on_new_day(_day_number: int) -> void:
	hide_talk_bubble()

func get_emotion_value() -> int:
	match state:
		State.HAPPY:
			return 1
		State.SAD:
			return -1
		_:
			return 0
			
func is_unlocked() -> bool:
	return state != State.LOST
	
func minigame_triggered() -> void:
	if has_joined:
		return
	if not pipe_check():
		await say_this("Your pipes seemed to have dissapeared")
		return
	has_triggered_minigame = true
	
	print("Minigame would happen here!")
	
	var temp_minigameresult := true
	complete_minigame(temp_minigameresult)
	
func complete_minigame(was_success: bool) -> void:
	has_triggered_minigame = false
	
	if not was_success:
		await say_this("Blub! Let's try again with more pipes!")
		return
	if not pipe_check():
		await say_this("We need more pipes!")
		return
	use_pipes()
	
	has_joined = true
	state = State.HAPPY
	move_to_basement()
	
	if fish_text != null:
		fish_sprite.texture = fish_text
	emit_emotion_changed()
	await say_this("I'll move to basement tank now!")

func use_pipes() -> void:
	var main := get_tree().current_scene
	if main == null:
		return
	if main.has_method("remove_item"):
		main.remove_item("pipe", 10)
	else:
		push_warning("Function not found in main: remove_item")

func move_to_basement() -> void:
	var main := get_tree().current_scene
	
	if main == null:
		return
	
	var basement := main.get_node_or_null("basement")
	if basement == null:
		push_warning("BASEMENT could not be found")
		return
	
	#ADD PSAWN LOGIC HERE!
