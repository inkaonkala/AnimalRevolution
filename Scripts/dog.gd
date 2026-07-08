extends AnimalBase

enum State {
	LOST,
	FOUND,
	HAPPY,
	SAD,
	ANGRY,
	NEUTRAL
}

@export var dog_name := "Tilly"
@export var spawn_index := 0

var state := State.LOST
var has_joined := false
var days_without_food := 0


func _ready() -> void:
	species = "dog"
	intro_lines = [
		"Ohoy! I wat to join the revolution too!"
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
			await say_this("Dogs rule!")
		State.SAD:
			await say_this("I want BEEF")
		_:
			await say_this("I am bored")
		
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
