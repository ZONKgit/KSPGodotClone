extends Node

var parts_data: Dictionary = {}
var load_output = null

func _ready():
	load_game()

func load_game() -> void:
#	var model = preload("res://Parts/command/mk1/model.obj")
#	$"../../MeshInstance3D".mesh = model
	# Загрузка деталей
	for part_type in get_parts_types_in_derictory():
		var parts = {}
		for part in get_parts_in_derictory(part_type):
			var part_config_file = FileAccess.open("res://Parts/"+part_type+"/"+part+"/config.json", FileAccess.READ)
			var part_config_string = part_config_file.get_as_text()
			var part_config = JSON.parse_string(part_config_string)

			var part_model = load("res://Parts/"+part_type+"/"+part+"/model.obj")
			# Загрузка параментов детали
			parts[part] = {
				"name" : part_config.name,
				"mesh" : part_model,
				"top_attach_point" : part_config.top_attach_point,
				"bottom_attach_point" : part_config.bottom_attach_point
			}
			
		parts_data[part_type] = parts
	#print(parts_data)

func get_parts_types_in_derictory():
	var dir = DirAccess
	var part_types = dir.get_directories_at("res://Parts/")
	return part_types

func get_parts_in_derictory(type: String):
	var dir = DirAccess
	var parts = dir.get_directories_at("res://Parts/"+type)
	return parts

func get_parts_types():
	return parts_data.keys()

func get_parts(type: String):
	return parts_data[type].keys()

func get_part_data(type:String, part:String):
	return parts_data[type][part]

func get_part_data_by_name(part: String):
	return get_part_data(get_part_type_by_name(part), part)

func get_part_type_by_name(part):
	for part_type in parts_data.keys():
		if parts_data[part_type].has(part):
			return part_type

func has_part_by_name(part) -> bool:
	for part_type in parts_data.keys():
		if parts_data[part_type].has(part):
			return true
	return false
