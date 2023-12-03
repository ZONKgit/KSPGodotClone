extends Part
class_name liquidEngine

@export var trust: float = 0.0

func _physics_process(delta):
	if link != "":
		engineForce()

func engineForce() -> void:
	if link_node.fuel >= 0:
		space_ship.add_constant_central_force(Vector3(0,trust*space_ship.trust_level,0))
