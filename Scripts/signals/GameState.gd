extends Node

var cat_found := false
var hamster_found := false
var dog_found := false
var tagging_unlocked := false
var bottle_full := false

var meat := 0
var butschered_lastnight := 0
var money := 0

var tagged_humans: Array = []


func register_tagged_humans(human: Node) -> void:
	for human_data in tagged_humans:
		if human_data["human"] == human:
			return

	tagged_humans.append({
		"human": human,
		"nights_left": 5
	})

	print("Registered tagged human. Count: ", tagged_humans.size())

	
func process_nigt() -> void:
	butschered_lastnight = 0
	var finished_humans := []
	
	for human_data in tagged_humans:
		var human = human_data["human"]
		
		if not is_instance_valid(human):
			finished_humans.append(human_data)
			continue
			
		meat += 1
		butschered_lastnight += 1
		human_data["nights_left"] -= 1
		
		if human_data["nights_left"] <= 0:
			human.queue_free()
			finished_humans.append(human_data)
	
	for human_data in finished_humans:
		tagged_humans.erase(human_data)

	print("Night processed. Meat total: ", meat)
	print("Butchered last night: ", butschered_lastnight)
