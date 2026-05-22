extends CanvasLayer

@onready var time_icon: TextureRect = $TimeIcon

#IVENTORY
@onready var inv_slots := [
	{
		"icon": $SideBarUI/TextureRect0,
		"label": $SideBarUI/TextureRect0/InveZero
	},
	{
		"icon": $SideBarUI/TextureRect1,
		"label": $SideBarUI/TextureRect1/Inve1
	},
	{
		"icon": $SideBarUI/TextureRect2,
		"label": $SideBarUI/TextureRect2/Inve2
	},
	{
		"icon": $SideBarUI/TextureRect3,
		"label": $SideBarUI/TextureRect3/Inve3
	},
	{
		"icon": $SideBarUI/TextureRect4,
		"label": $SideBarUI/TextureRect4/Inve4
	}
]

var item_icons := {
	"seed": preload("res://Assets/Collectables/ballB.png"),
	"bottle": preload("res://Assets/Collectables/bottle.png"),
	"hamsterbaby": preload("res://Assets/Collectables/hamsterbaby.png"),
	"crop": preload("res://Assets/Plants/carrot.png")
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

func _on_time_changed(time_name: String) -> void:
	time_icon.texture = icons[time_name]
