extends Node3D

func generate_line_mesh(points: Array):
	var immediate_mesh = ImmediateMesh.new()
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for point in points:
		immediate_mesh.surface_add_vertex(point)
	immediate_mesh.surface_end()

	return immediate_mesh

var traj = []


func _process(delta):
	# Предположим, что у вас есть начальная линейная скорость и текущая позиция
	var initial_velocity: Vector3 = $space_ship2.linear_velocity
	var initial_position: Vector3 = $space_ship2.global_position
	var body = $space_ship2
	# Ускорение и направление из вашего кода
	var direction_to_planet: Vector3 = ($earth.global_position - body.global_position).normalized()
	var distance: float = $earth.global_position.distance_to(body.global_position)
	var strength: float = 9.8 * (body.mass * $earth.mass) / (distance * distance)
	
	
	var time_step: float = 1000/body.time_speed  # Временной шаг в секундах
	var total_time: float = 10000000/body.time_speed  # Общее время в секундах (здесь 10 секунд, замените на нужное вам значение)
	var num_steps: int = int(total_time / time_step)

	# Очистите массив traj перед началом новых вычислений
	var traj = []

	for i in range(num_steps + 1):
		var current_time: float = delta*(i * time_step)

		# Вычисление новой позиции для текущего времени
		var new_position: Vector3 = initial_position + initial_velocity * current_time + 0.5 * direction_to_planet * strength * current_time * current_time

		# Добавление новой позиции в массив traj
		traj.append(new_position)
	$space_ship_traj.mesh = generate_line_mesh(traj)
