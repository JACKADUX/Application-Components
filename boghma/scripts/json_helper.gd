class_name JsonHelper extends Resource

static func load_meta(json_path):
	if not FileAccess.file_exists(json_path):
		return {}
	var file = FileAccess.open(json_path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

static func save_meta(json_path, file_data):
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(file_data))
