extends StaticBody3D

@onready var grid_shader_material = preload("res://resources/vab/grid_shader_material.tres")
@onready var part_hover_material = preload("res://resources/vab/part_hover_material.tres")
@onready var vab = $".."
@onready var static_body: StaticBody3D = self
@onready var mesh_instance: MeshInstance3D = $mesh

var is_grabbed: bool = false # Схвачен объект
var is_hover: bool = false # Наведено на объект
var top_attach_point
var bottom_attach_point
var top_attach_node_name
var bottom_attach_node_name
#var connected_parts: Array =[] # Список деталей которые присоеденны к этой

# Присоеденение другой детали к этой
func connect_part(part: StaticBody3D, dir: String) -> void:
	#if connected_parts.has(part): return # or part.connected_parts.has(self)
	#connected_parts.append(part)
	if dir == "top":
		top_attach_node_name = part.name
		part.bottom_attach_node_name = name
	elif dir == "bottom":
		bottom_attach_node_name = part.name
		part.top_attach_node_name = name

# Отсоеденение другой детали от этой
func disconnect_part(part: StaticBody3D, dir: String) -> void:
#	if !connected_parts.has(part): return
#	connected_parts.remove_at(connected_parts.find(part))
	if dir == "top": top_attach_node_name = null
	else: bottom_attach_node_name = null

func part_settings(part_mesh: Mesh, part_name: String, top_attach_point: Array, bottom_attach_point: Array):
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
	# Добавление группы именни к детали
	self.add_to_group(name)
	#Добавление точек соеденения
	print(top_attach_point)
	print(bottom_attach_point)
	#Основные настройки
	var top_attach_mesh_instance = MeshInstance3D.new()
	top_attach_mesh_instance.mesh = SphereMesh.new()
	top_attach_mesh_instance.position = Vector3(top_attach_point[0], top_attach_point[1], top_attach_point[2])
	#Настройки в зависимости от типа
	if top_attach_point[3] == "norm":
		top_attach_mesh_instance.mesh.surface_set_material(0,grid_shader_material.duplicate())
		top_attach_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("background_color", Color(0,1,0))
		top_attach_mesh_instance.mesh.radius = 0.3
		top_attach_mesh_instance.mesh.height = 0.6
	elif top_attach_point[3] == "min":
		top_attach_mesh_instance.mesh.surface_set_material(0,grid_shader_material.duplicate())
		top_attach_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("background_color", Color(1,0,1))
		top_attach_mesh_instance.mesh.radius = 0.15
		top_attach_mesh_instance.mesh.height = 0.3
	add_child(top_attach_mesh_instance)
	# Настройка точек соеденения
	self.top_attach_point = top_attach_mesh_instance
	
	#Нижняя точка
	#Основные настройки
	var bottom_attach_mesh_instance = MeshInstance3D.new()
	bottom_attach_mesh_instance.mesh = SphereMesh.new()
	bottom_attach_mesh_instance.position = Vector3(bottom_attach_point[0], bottom_attach_point[1], bottom_attach_point[2])
	#Настройки в зависимости от типа
	if bottom_attach_point[3] == "norm":
		bottom_attach_mesh_instance.mesh.surface_set_material(0,grid_shader_material.duplicate())
		bottom_attach_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("background_color", Color(0,1,0))
		bottom_attach_mesh_instance.mesh.radius = 0.3
		bottom_attach_mesh_instance.mesh.height = 0.6
	elif bottom_attach_point[3] == "min":
		bottom_attach_mesh_instance.mesh.surface_set_material(0,grid_shader_material.duplicate())
		bottom_attach_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("background_color", Color(1,0,1))
		bottom_attach_mesh_instance.mesh.radius = 0.15
		bottom_attach_mesh_instance.mesh.height = 0.3
	add_child(bottom_attach_mesh_instance)
	# Настройка точек соеденения
	self.bottom_attach_point = bottom_attach_mesh_instance

func _process(delta):
	
	if !is_hover or !is_grabbed:
		if top_attach_node_name != null:
			global_position = get_tree().get_nodes_in_group(top_attach_node_name)[0].global_position+bottom_attach_point.position+bottom_attach_point.position
	
	# Объект схвачен
	if is_grabbed:
		global_position = vab.cursor_position
		# Свиг всех присоеденных деталей
#		for connected_part in connected_parts:
#			if bottom_attach_point == connected_part:
		
		
		#Отпустить объект
		if Input.is_action_just_pressed("grab"):
			set_is_grabed(!is_grabbed)
		
		
		# Соеденение нод
		var top_to_bottom_dist = Vector3(0,0,0)
		var bottom_to_top_dist = Vector3(0,0,0)
		for node in get_tree().get_nodes_in_group("part"):
			if node != self:
				# к нижней
				top_to_bottom_dist = node.bottom_attach_point.global_position.distance_to(top_attach_point.global_position)
				if top_to_bottom_dist < 0.3:
					var relative_position = top_attach_point.global_position - global_position
					global_position = node.global_position - node.top_attach_point.position - top_attach_point.position
					node.connect_part(self, "bottom")
				else: # Отсоеденение связи соеденения этой и рядом находящийся ноды
					node.disconnect_part(self, "bottom")
				
				# к верхней
				if node.is_grabbed:
					bottom_to_top_dist = node.top_attach_point.global_position.distance_to(bottom_attach_point.global_position)
					if bottom_to_top_dist < 0.3:
						var relative_position = bottom_attach_point.global_position - global_position
						global_position = node.global_position - node.bottom_attach_point.position - bottom_attach_point.position
						node.connect_part(self, "top")
					else:# Отсоеденение связи соеденения этой и рядом находящийся ноды
						node.disconnect_part(self, "top")
	
	
		
		
#	if bottom_attach_node_name != null:
#		get_tree().get_nodes_in_group(bottom_attach_node_name)[0].global_position = global_position+bottom_attach_point.position+bottom_attach_point.position
	
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
