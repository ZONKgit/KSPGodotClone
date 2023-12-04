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
		"pos" : Vector3(0,0.24,0), # Позиция
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
var gyrodine_strenght: float = 0.05 # Сила гиродина (Надо зпменить на 0 как только появяться модули гиродина и командные блоки)

var time_speed: int # Ускорение времени

var time = 0

func generate_line_mesh(points: Array, color: Color):
	var immediate_mesh = ImmediateMesh.new()
	var material = ORMMaterial3D.new()
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)
	for point in points:
		immediate_mesh.surface_add_vertex(point)
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	return immediate_mesh


func _process(delta):
	time+=delta
	if time == int(time):
		print(time)
	

func _physics_process(delta):
	# Убирание вращения (Попытка в SAS)
	if !Input.is_action_pressed("pitch_add") and !Input.is_action_pressed("pitch_remove"):
		if !Input.is_action_pressed("yaw_add") and !Input.is_action_pressed("yaw_remove"):
			if !Input.is_action_pressed("roll_add") and !Input.is_action_pressed("roll_remove"):
				angular_velocity -= angular_velocity*gyrodine_strenght
func update_ui() -> void:
	trust_progress.value = float(trust_level)
func _ready():
	continuous_cd = true # Включение детального анализа столкновений
	load_craft()
	$line.mesh = generate_line_mesh([Vector3(0,0,0), Vector3(0,1,0), Vector3(1,0,1)], Color8(1,0,0))
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
	# Упарвление тягой
	if Input.is_action_pressed("add_thrust"):
		if trust_level < 1:
			trust_level += trust_sensitivity
			update_ui()
	elif Input.is_action_pressed("remove_thrust"):
		if trust_level > 0:
			trust_level -= trust_sensitivity
			update_ui()
	# Управление временем
	if Input.is_action_pressed("add_time_speed"):
		if time_speed < 4:
			time_speed += 1
			Engine.time_scale = time_speed
	elif Input.is_action_pressed("remove_time_speed"):
		if time_speed > 1:
			time_speed -= 1
			Engine.time_scale = time_speed
			
	# Управление вращением
	if Input.is_action_pressed("pitch_add"):
		apply_torque_impulse(rotation+Vector3(10,0,0))
	elif Input.is_action_pressed("pitch_remove"):
		apply_torque_impulse(rotation+Vector3(-10,0,0))
	if Input.is_action_pressed("yaw_add"):
		apply_torque_impulse(rotation+Vector3(0,0,10))
	elif Input.is_action_pressed("yaw_remove"):
		apply_torque_impulse(rotation+Vector3(0,0,-10))
	if Input.is_action_pressed("roll_add"):
		apply_torque_impulse(rotation+Vector3(0,10,0))
	elif Input.is_action_pressed("roll_remove"):
		apply_torque_impulse(rotation+Vector3(0,-10,0))
