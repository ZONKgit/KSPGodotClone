extends StaticBody3D

@onready var grid_shader_material = preload("res://resources/vab/grid_shader_material.tres")
@onready var part_hover_material = preload("res://resources/vab/part_hover_material.tres")
@onready var vab = $".."
@onready var static_body: StaticBody3D = self
@onready var mesh_instance: MeshInstance3D = $mesh

var is_grabbed: bool = false
var is_hover: bool = false
var attach_points: Array = []  # Список точек привязки для текущей детали


func part_settings(part_mesh: Mesh, part_name: String, attach_points: Array):
	mesh_instance.mesh = part_mesh
	name = part_name
	# Доабвление материала
	mesh_instance.material_overlay = part_hover_material.duplicate()
	# Создание коллизии
	mesh_instance.create_convex_collision()
	static_body = get_node("mesh/mesh_col")
	static_body.mouse_entered.connect(_on_mouse_entered)
	static_body.mouse_exited.connect(_on_mouse_exited)
	# Хват детали
	set_is_grabed(true)
	#Добавление точек соеденения
	print(attach_points)
	for attach in attach_points:
		#Основные настройки
		var attach_mesh_instance = MeshInstance3D.new()
		attach_mesh_instance.mesh = SphereMesh.new()
		attach_mesh_instance.position = Vector3(attach[0], attach[1], attach[2])
		#Настройки в зависимости от типа
		if attach[3] == "norm":
			attach_mesh_instance.mesh.surface_set_material(0,grid_shader_material.duplicate())
			attach_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("background_color", Color(0,1,0))
			attach_mesh_instance.mesh.radius = 0.3
			attach_mesh_instance.mesh.height = 0.6
		elif attach[3] == "min":
			attach_mesh_instance.mesh.surface_set_material(0,grid_shader_material.duplicate())
			attach_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("background_color", Color(1,0,1))
			attach_mesh_instance.mesh.radius = 0.15
			attach_mesh_instance.mesh.height = 0.3
		add_child(attach_mesh_instance)
		# Настройка точек соеденения
		self.attach_points.append(attach_mesh_instance)

func _process(delta):
	# Объект схвачен
	if is_grabbed:
		global_position = vab.cursor_position
		#Опустить объект
		if Input.is_action_just_pressed("grab"):
			set_is_grabed(!is_grabbed)
		
		
		var dist = Vector3(0,0,0)
		for node in get_tree().get_nodes_in_group("part"):
			if node != self:
				dist = node.attach_points[1].global_position.distance_to(attach_points[0].global_position)
				if dist < 0.3:
					var relative_position = attach_points[0].global_position - global_position
					global_position = node.global_position - node.attach_points[0].position - attach_points[0].position
					print("self: ", global_position, " to: ", attach_points[0].global_position)
	
	# Наведенно на объект
	if is_hover:
		# Схвавтить объект
		if Input.is_action_just_pressed("grab"):
			set_is_grabed(!is_grabbed)

func set_is_grabed(value:bool) -> void:
	static_body.set_collision_layer_value(1, !value)
	is_grabbed = value
	is_hover = false
	if value:
		mesh_instance.material_overlay.set_shader_parameter("outline_color", Color(0,1,0,0.9))
	else:
		mesh_instance.material_overlay.set_shader_parameter("outline_color", Color(0,0,0,0))

func set_is_hover(value:bool) -> void:
	is_hover = value
	if value:
		mesh_instance.material_overlay.set_shader_parameter("outline_color", Color(0.5,0.5,0.5,0.9))
	else:
		if is_grabbed:
			mesh_instance.material_overlay.set_shader_parameter("outline_color", Color(0,1,0,0.9))
			return
		mesh_instance.material_overlay.set_shader_parameter("outline_color", Color(0,0,0,0))
	

func _on_mouse_entered():
	set_is_hover(true)


func _on_mouse_exited():
	set_is_hover(false)
