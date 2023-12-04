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
	$space_ship_traj.mesh = generate_line_mesh(traj)
	$update_traj
