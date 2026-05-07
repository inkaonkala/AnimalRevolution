extends CanvasLayer

@onready var time_icon: TextureRect = $TimeIcon

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
