extends Area2D

@onready var speak_bubble = $Label

enum State
{
	LOST,
	HAPPY,
	SAD,
	WORKING,
	HUNGRY,
	NEEDS_THERAPY
}

var state := State.LOST

var work_nights := 0
var hunger_timer := 0
var humans_in_factory := false
var meat_produced := 0

func _ready() -> void:
	DayCycle.new_day.connect(cat_new_day)
	body_entered.connect(cat_activated)
	
func cat_new_day(daynmb: int) -> void:
	on_new_day()
	

func on_new_day() -> void:
	if state == State.HAPPY:
		hunger_timer += 1
	if hunger_timer >= 3:
		become_hungry()
		
	elif state == State.WORKING:
		butcher()
		work_nights += 1
		
		if work_nights >= 3:
			need_therapy()

func cat_talk(text: String) -> void:
		speak_bubble.text = text
		speak_bubble.visible = true
		await  get_tree().create_timer(1.5). timeout
		speak_bubble.visible = false

func cat_activated(body: Node) -> void:
	if body.name != "Player":
		return
		
	if state == State.LOST:
		state = State.HAPPY
		GameState.cat_found = true
		await cat_talk("Why not? I'll joi the revolution")
		print("Cat found!")
		return
	
	if state == State.HUNGRY:
		GameState.tagging_unlocked = true
		await cat_talk("Use this TAG to mark humans good wnought to eat")
		return

func become_hungry() ->void:
	state = State.HUNGRY
	#GameState.tagging_unlocked = true
	print("Cat's hungry!")
	
func butcher() -> void:
	state = State.WORKING
	print("Cat's butshering the human")

func need_therapy() -> void:
	state = State.NEEDS_THERAPY
	print("Cat's in need of threrapy")
