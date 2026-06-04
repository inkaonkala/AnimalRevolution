extends StaticBody2D

@export var open_on_time := true
@export var open_time := "evening"

@export var open_every_x_days := 0 # 0 = ignore the rule
@export var open_on_exact_day := 0

@export var starts_open := false

var is_open := false

func _ready() -> void:
	DayCycle.time_changed.connect(_check_door)
	DayCycle.new_day.connect(_on_new_day)

	if starts_open:
		open_door()
	else:
		close_door()

	_check_door(DayCycle.get_time())


func _on_new_day(_day_number: int) -> void:
	_check_door(DayCycle.get_time())


func _check_door(_time_name: String) -> void:
	if should_be_open():
		open_door()
	else:
		close_door()


func should_be_open() -> bool:
	if open_on_time and DayCycle.get_time() != open_time:
		return false

	if open_every_x_days > 0:
		if DayCycle.day_nmb % open_every_x_days != 0:
			return false

	if open_on_exact_day > 0:
		if DayCycle.day_nmb != open_on_exact_day:
			return false

	return true


func open_door() -> void:
	is_open = true
	$CollisionShape2D.disabled = true
	visible = false


func close_door() -> void:
	is_open = false
	$CollisionShape2D.disabled = false
	visible = true
