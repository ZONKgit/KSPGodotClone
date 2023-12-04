extends Marker3D

@onready var camera = $Camera3D
@onready var sensitivity = 0.003

var camera_rot = Vector3(0,0,0)

func _process(_delta):
	global_rotation = camera_rot

func _input(e):
	if e is InputEventMouseMotion:
		if Input.is_action_pressed("vab_grab"):
			camera_rot.y -= e.relative.x * sensitivity
			camera_rot.x = clamp(camera_rot.x-e.relative.y * sensitivity, -1.4, 1.4)
	if Input.is_action_just_pressed("map"):
		if camera.position.z == 3:
			camera.position.z = 16000
		elif camera.position.z == 16000:
			camera.position.z = 3
