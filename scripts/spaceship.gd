extends RigidBody3D
class_name SpaceShip

var parts = {
	"fuelTankT100" : {
		"scene" : "res://scenes/part/fuelTankT100.tscn"
	},
	"liquidEngineT100" : {
		"scene" : "res://scenes/part/liquidEngineT100.tscn"
	}
}

var ship_data = [
	{
		"part" : "fuelTankT100", # Деталь
		"name" : "fuelTankT100_1", # Имя в крфте
		"pos" : Vector3(0,1,0), # Позиция
	},
	{
		"part" : "liquidEngineT100", # Деталь
		"name" : "liquidEngineT100_1", # Имя в крфте
		"pos" : Vector3(0,0,0), # Позиция
		"link" : "fuelTankT100_1", # Соеденено с ... деталью
	}
]

@onready var trust_progress = $screen/ui/trust_progress

var trust_sensitivity: float = 0.1 # Скорость изменение уровня тяги
var trust_level: float = 0 # Урвоень тяги

func update_ui() -> void:
	trust_progress.value = float(trust_level)
func _ready():
	load_craft()
func load_craft() -> void:
	for detail in ship_data:
		create_part(detail)
func create_part(part_data) -> void:
	var part_scene_path = parts[part_data.part].scene
	var part_scene = load(part_scene_path).instantiate()
	part_scene.name = part_data.name
	part_scene.position = part_data.pos
	if "link" in part_data: part_scene.link = part_data.link
	add_child(part_scene)
func _input(event):
	if Input.is_action_pressed("add_trus"):
		if trust_level < 1:
			trust_level += trust_sensitivity
			update_ui()
	elif Input.is_action_pressed("remove_trust"):
		if trust_level > 0:
			trust_level -= trust_sensitivity
			update_ui()
