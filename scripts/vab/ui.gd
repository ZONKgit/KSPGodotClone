extends Control

@onready var vab = $"../.."

@onready var parts_types_container = $parts_panel/parts_panel_container/parts_types_container
@onready var parts_container = $parts_panel/parts_panel_container/parts_container

# Called when the node enters the scene tree for the first time.
func _ready():
	load_parts_types()

func load_parts_types() -> void:
	# Загрузка типов
	var part_types = LoadGame.get_parts_types()
	print(part_types)
	# Добавление кнопок
	for type in part_types:
		var part_button = Button.new()
		part_button.custom_minimum_size = Vector2(64,64)
		part_button.text = str(type)
		part_button.pressed.connect(load_parts.bind(type))

		parts_types_container.add_child(part_button)


func load_parts(type: String) -> void:
	# Загрузка деталей
	var parts = LoadGame.get_parts(type)
	# Удаление старых кнопок
	for child in parts_container.get_children():
		child.queue_free()
	# Добавление новых кнопок
	for part in parts:
		var part_button = Button.new()
		part_button.custom_minimum_size = Vector2(64,64)
		part_button.text = str(part)
		part_button.pressed.connect(vab.create_part.bind(type, part))
		
		parts_container.add_child(part_button)


