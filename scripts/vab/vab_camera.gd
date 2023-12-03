extends Marker3D

@onready var camera = $camera
@onready var camera_orthogonal = $cameraOtrogonal

var sensitivity = 0.003
var camera_speed = 0.5

var time: float = 0.0

func _process(delta):
	time += delta * 0.01

func _input(e):
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_action_pressed("camera_rotate"):
			if e is InputEventMouseMotion:
				# Двигаем камеру вместо вращения при удержании Shift
				var move_vector = Vector3(-e.relative.x * sensitivity * 2, e.relative.y * sensitivity * 2, 0)
				move_vector = global_transform.basis * move_vector
				position += move_vector
	elif Input.is_action_pressed("camera_rotate"):
		if e is InputEventMouseMotion:
			rotation.y -= e.relative.x * sensitivity
			rotation.x = clamp(rotation.x-e.relative.y * sensitivity, -1.4, 1.4)
	
	if Input.is_key_pressed(KEY_SHIFT):
		if e is InputEventMouseButton:
			if e.pressed:
				if Input.is_action_just_pressed("vab_camera_up") && camera.transform.origin.z > -30:
					camera.transform.origin.z -= camera_speed
					camera_orthogonal.transform.origin.z -= camera_speed
				if Input.is_action_just_pressed("vab_camera_down") && camera.transform.origin.z < 30:
					camera.transform.origin.z += camera_speed
					camera_orthogonal.transform.origin.z += camera_speed
				camera_orthogonal.size = transform.origin.z*(4/9)
	elif e is InputEventMouseButton:
		if e.pressed:
			if Input.is_action_just_pressed("vab_camera_up")  && camera.transform.origin.y > -30:
				transform.origin.y += camera_speed
			if Input.is_action_just_pressed("vab_camera_down")  && camera.transform.origin.y < 30:
				transform.origin.y -= camera_speed
