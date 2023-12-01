extends Node3D

@onready var terrain = $VoxelLodTerrain
@onready var atmosphere = $PlanetAthmosphere

func _ready():
	setup_planet()

func setup_planet():
	var body = {
		"name" : "Planet",
		"radius" : 6371,
	}
	var generator : VoxelGeneratorGraph = terrain.generator
	var graph : VoxelGraphFunction = generator.get_main_function()
	var sphere_node_id := graph.find_node_by_name("sphere")
	# TODO Need an API that doesnt suck
	var radius_param_id := 0
	graph.set_node_param(sphere_node_id, radius_param_id, body.radius)
	var ravine_blend_noise_node_id := graph.find_node_by_name("ravine_blend_noise")
	var noise_param_id := 0
	var ravine_blend_noise = graph.get_node_param(ravine_blend_noise_node_id, noise_param_id)
	ravine_blend_noise.seed = body.name.hash()
	var cave_height_node_id := graph.find_node_by_name("cave_height_subtract")
	graph.set_node_default_input(cave_height_node_id, 1, body.radius - 100.0)
	var cave_noise_node_id := graph.find_node_by_name("cave_noise")
	var cave_noise = graph.get_node_param(cave_noise_node_id, noise_param_id)
	cave_noise.period = 900.0 / body.radius
	var ravine_depth_multiplier_node_id := graph.find_node_by_name("ravine_depth_multiplier")
	var ravine_depth : float = graph.get_node_default_input(ravine_depth_multiplier_node_id, 1)

	graph.set_node_default_input(ravine_depth_multiplier_node_id, 1, ravine_depth)
	# var cave_height_multiplier_node_id = generator.find_node_by_name("cave_height_multiplier")
	# generator.set_node_default_input(cave_height_multiplier_node_id, 1, 0.015)
	generator.compile()

	generator.use_subdivision = true
	generator.subdivision_size = 8
	#generator.sdf_clip_threshold = 10.0
	generator.use_optimized_execution_map = true

	atmosphere.planet_radius = body.radius
