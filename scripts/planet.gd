extends StaticBody3D
class_name PlanetBody

@export var mass = 5978*10

var body = {
	"name" : "Planet",
	"radius" : 637.1,
}

@onready var terrain = $terrain
@onready var atmosphere = $PlanetAthmosphere

var affected_bodies: Array = []

func _on_body_trigger_body_entered(body):
	if body is SpaceShip:
		affected_bodies.append(body)

func _on_body_trigger_body_exited(body):
	if body in affected_bodies:
		affected_bodies.remove_at(affected_bodies.find(body))

func _process(delta):
	# Вращение луны
	$moon_orbit.rotation.z += 1

func _physics_process(delta):
	# Расцчет гравитации
	for body in affected_bodies:
		var direction_to_planert: Vector3 = (global_position - body.global_position).normalized()
		
		var distance: float = global_position.distance_to(body.global_position)
		var strenght: float = 9.8*(body.mass * mass) / (distance*distance)
		body.apply_impulse(direction_to_planert*strenght, body.global_position)

func _ready():
	$PlanetAthmosphere.sun_path = "../sun/DirectionalLight3D"
	setup_planet()
	
	add_to_group("planet")


func setup_planet():
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



