extends Area2D

var player_inside := false

func _ready() -> void:
	body_entered.connect(body_enter)
	body_exited.connect(body_exit)

func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		sleep_until_morning()

func body_enter(body: Node) -> void:
	if body.name == "Player":
		player_inside = true

func body_exit(body: Node) -> void:
	if body.name == "Player":
		player_inside = false

func sleep_until_morning() -> void:
	GameState.process_nigt()
	
	DayCycle.current_time = DayCycle.ToD.MORNING
	DayCycle.day_nmb += 1
	DayCycle.timer = 0.0
	print("It's a Morning! Day number: ", DayCycle.day_nmb)
	print("Meat produced last night: ", GameState.butschered_lastnight)
	

	DayCycle.new_day.emit(DayCycle.day_nmb)
	DayCycle.time_changed.emit(DayCycle.get_time())

#UNCOMMENT FOR NIGHT!
#	get_tree().change_scene_to_file("res://Scenes/Night.tscn")
