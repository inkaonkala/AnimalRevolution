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
		

func first_meeting() -> void:
	await super.first_meeting()
	state = State.NEUTRAL
	emit_emotion_changed()
	
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
		State.SAD, State.ANGRY:
			return -1
		_:
			return 0
			
func is_unlocked() -> bool:
	return state != State.LOST
