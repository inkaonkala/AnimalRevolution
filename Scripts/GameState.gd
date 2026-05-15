extends Node

var cat_found := false
var hamster_found := false
var tagging_unlocked := false

var meat := 0
var butschered_lastnight := 0

var money := 0

var tagged_humans: Array = []

func reset_night() -> void:
	butschered_lastnight = 0
	
func register_tagged_humans(human: Node) -> void:
	if human not in tagged_humans:
		tagged_humans.append(human)
		print("Registered tagged human. Count: ", tagged_humans.size())
	
func process_nigt() -> void:
	reset_night()	
	
	for human in tagged_humans:
		if is_instance_valid(human):
			human.queue_free()
			meat += 1
			butschered_lastnight += 1
			
	print("Night processed. Meat total: ", meat)
	tagged_humans.clear()	 	
