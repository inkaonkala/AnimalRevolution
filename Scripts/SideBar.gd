extends CanvasLayer

@onready var time_icon: TextureRect = $TextureRect/TimeIcon

#IVENTORY
@onready var inv_slots := [
	{
		"icon": $TextureRect/SideBarUI/TextureRect0,
		"label": $TextureRect/SideBarUI/TextureRect0/InveZero
	},
	{
		"icon": $TextureRect/SideBarUI/TextureRect1,
		"label": $TextureRect/SideBarUI/TextureRect1/Inve1
	},
	{
		"icon": $TextureRect/SideBarUI/TextureRect2,
		"label": $TextureRect/SideBarUI/TextureRect2/Inve2
	},
	{
		"icon": $TextureRect/SideBarUI/TextureRect3,
		"label": $TextureRect/SideBarUI/TextureRect3/Inve3
	},
	{
		"icon": $TextureRect/SideBarUI/TextureRect4,
		"label": $TextureRect/SideBarUI/TextureRect4/Inve4
	}
]

var item_icons := {
	"carrot_seed": preload("res://Assets/Collectables/ballB.png"),
	"eggplant_seed": preload("res://Assets/Collectables/munaseed.png"),
	"bottle": preload("res://Assets/Collectables/bottle.png"),
	"hamsterbaby": preload("res://Assets/Collectables/hamsterbaby.png"),
	"carrot": preload("res://Assets/Plants/carrot.png"),
	"flower1_seed": preload("res://Assets/Collectables/kukka1seed.png"),
	"flower2_seed": preload("res://Assets/Collectables/kukka2seed.png"),
	"flower1": preload("res://Assets/Plants/kukka1.png"),
	"flower2": preload("res://Assets/Plants/kukka2.png"),
	"eggplant": preload("res://Assets/Plants/munakoiso.png")
}

#FACES

@onready var cat_face: TextureRect = $TextureRect/AnimalFaces/CatFace
@onready var rodent_face: TextureRect = $TextureRect/AnimalFaces/RodentFace
@onready var dog_face: TextureRect = $TextureRect/AnimalFaces/DogFace

@onready var animal_faces := {
	"cat": cat_face,
	"dog": dog_face,
	"rodent": rodent_face
}

var face_icons := {
	"happy": preload("res://Assets/characters/happy.png"),
	"sad": preload("res://Assets/characters/sad.png"),
	"neutral": preload("res://Assets/characters/neutral.png")
}


func update_inventory_ui(inventory: Dictionary, item_order: Array) -> void:
	for slot in inv_slots:
		slot["icon"].texture = null
		slot["icon"].visible = false
		slot["label"].text = ""
		slot["label"].visible = false

	for i in range(min(item_order.size(), inv_slots.size())):
		var item_id = item_order[i]
		var amount = inventory.get(item_id, 0)

		if amount <= 0:
			continue

		inv_slots[i]["icon"].visible = true
		inv_slots[i]["icon"].texture = item_icons.get(item_id, null)

		inv_slots[i]["label"].visible = true
		inv_slots[i]["label"].text = str(amount)

#DAY AND NIGHT CYCLE
var icons := {
	"morning": preload("res://Assets/SideBar/morning.png"),
	"day": preload("res://Assets/SideBar/day.png"),
	"evening": preload("res://Assets/SideBar/evening.png"),
	"night": preload("res://Assets/SideBar/night.png")
}


func _ready() -> void:
	DayCycle.time_changed.connect(_on_time_changed)
	_on_time_changed(DayCycle.get_time())

	DayCycle.new_day.connect(func(_day): update_animal_emotions())
	update_animal_emotions()
	
func _on_time_changed(time_name: String) -> void:
	time_icon.texture = icons[time_name]

#ANIMAL EMOTIONS

func update_animal_emotions() -> void:
	for species in animal_faces.keys():
		update_emotion(species)

func update_emotion(species_name: String) -> void:
	var total := 0
	var count := 0

	for animal in get_tree().get_nodes_in_group("animals"):
		if animal.species == species_name and animal.has_method("get_emotion_value"):
			total += animal.get_emotion_value()
			count += 1

	if count == 0:
		animal_faces[species_name].visible = false
		return

	var average := float(total) / float(count)
	
	animal_faces[species_name].visible = true
	if average > 0.33:
		animal_faces[species_name].texture = face_icons["happy"]
	elif average < -0.33:
		animal_faces[species_name].texture = face_icons["sad"]
	else:
		animal_faces[species_name].texture = face_icons["neutral"]
