extends Node3D

@onready var camera = $camera/cameraOtrogonal
@onready var debug_cursor = $cursor
@onready var cursor_length: int = 6

var cursor_position: Vector3

func create_part(type: String, part: String) -> void:
	var part_data = LoadGame.get_part_data(type, part)
	var _part = preload("res://scenes/vab/part.tscn").instantiate()
	add_child(_part)
	_part.part_settings(part_data.mesh, part_data.name, part_data.top_attach_point, part_data.bottom_attach_point)

func _input(event):
	if event is InputEventMouseMotion:
		var m_pos = event.position
		var ray_start = camera.project_ray_origin(m_pos)
		var ray_end = ray_start + camera.project_ray_normal(m_pos) * cursor_length
		cursor_position = ray_end
		if raycast_from_mouse(event.position, 1) != {  }:
			cursor_position = raycast_from_mouse(event.position, 1).position
		debug_cursor.global_position = cursor_position

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * cursor_length
	var world3d : World3D = get_viewport().world_3d
	var space_state = world3d.direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)
