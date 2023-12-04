extends Part
class_name liquidEngine

# Характеристики ракетного двигателя
@export var thrust: float = 205.16*0.1  # тяга в ньютонах
@export var isp: float = 265.0*0.1  # импульсный импульс двигателя (Isp) в секундах
# Расход топлива в кг в секунду
var fuelFlow: float = thrust / isp

func _physics_process(_delta):
	if link != "":
		engineForce()

func engineForce() -> void:
	if link_node.fuel >= 0:
		space_ship.apply_central_impulse(global_transform.basis.y*thrust*space_ship.trust_level)
		$GPUParticles3D.process_material.initial_velocity_min = thrust*space_ship.trust_level
		$GPUParticles3D.process_material.initial_velocity_max = thrust*space_ship.trust_level
		#fuelFlow * space_ship.trust_level - Расход топлива
