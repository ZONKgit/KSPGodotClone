extends Node3D

@onready var othogonal_camera = $camera/cameraOtrogonal
@onready var camera = $camera/camera
@onready var debug_cursor = $cursor
@onready var cursor_length: int = 5

var cursor_position: Vector3
var grabbed_part = null

func create_part(type: String, part: String) -> void:
	var part_data = LoadGame.get_part_data(type, part)
	var _part = preload("res://scenes/vab/part.tscn").instantiate()
	add_child(_part)
	_part.part_settings(part_data.mesh, part_data.name, part_data.top_attach_point, part_data.bottom_attach_point)

func _process(delta):
	cursor_length = camera.position.z
	var m_pos = get_viewport().get_mouse_position()
	var ray_start =othogonal_camera.project_ray_origin(m_pos)
	var ray_end = ray_start +othogonal_camera.project_ray_normal(m_pos) * cursor_length
	cursor_position = ray_end
	if raycast_from_mouse(m_pos, 1) != {  }:
		cursor_position = raycast_from_mouse(m_pos, 1).position
	debug_cursor.global_position = cursor_position

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start =othogonal_camera.project_ray_origin(m_pos)
	var ray_end = ray_start +othogonal_camera.project_ray_normal(m_pos) * cursor_length
	var world3d : World3D = get_viewport().world_3d
	var space_state = world3d.direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)

