extends RigidBody3D
class_name Part

@onready var space_ship = get_parent()
var link_node = null

@onready var model: MeshInstance3D = get_node("MeshInstance3D")
var link: String = ""

func install() -> void:
	# Настройка путя до соедененной ноды
	if link != "": link_node = get_parent().get_node(link)
	# Заморозка физики (Будет обрабатываться в SpaceCraft)
	freeze = true
	# Создание и настрйка коллизии
	model.create_convex_collision()
	var collision = model.get_child(0).get_child(0)
	var static_body = model.get_child(0)
	static_body.remove_child(collision)
	get_parent().add_child(collision)

func _ready():
	install()
