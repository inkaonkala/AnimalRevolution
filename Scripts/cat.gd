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

func become_hungry() ->void:
	state = State.HUNGRY
	print("Cat's hungry!")
	
func butcher() -> void:
	print("Cat's butshering the human")

func need_therapy() -> void:
	print("Cat's in need of threrapy")
