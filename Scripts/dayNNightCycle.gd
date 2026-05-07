extends Node

signal time_changed(time_name: String)
signal new_day(day_number: int)

enum ToD
{
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

@export var cycle_lenght := 5.0 #SECONDS!

var current_time: ToD = ToD.MORNING
var day_nmb := 1
var timer:= 0.0

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= cycle_lenght:
		timer = 0.0
		changeTOD()

func changeTOD() -> void:
	current_time += 1
	
	if current_time > ToD.NIGHT:
		current_time = ToD.MORNING
		day_nmb += 1
		new_day.emit(day_nmb)
		
	time_changed.emit(get_time())

func get_time() -> String:
	match current_time:
		ToD.MORNING:
			return "morning"
		ToD.DAY:
			return "day"
		ToD.EVENING:
			return "evening"
		ToD.NIGHT:
			return "night"
			
	return "unknown"
	
func is_night() -> bool:
	return current_time == ToD.NIGHT
