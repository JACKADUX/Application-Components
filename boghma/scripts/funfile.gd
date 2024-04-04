class_name FunFile

static func delet_folder(source_folder:String) -> bool:
	assert(DirAccess.dir_exists_absolute(source_folder))
	for file in DirAccess.get_files_at(source_folder):
		DirAccess.remove_absolute(source_folder.path_join(file))
	for folder in DirAccess.get_directories_at(source_folder):
		delet_folder(source_folder.path_join(folder))
	DirAccess.remove_absolute(source_folder)
	return true
	
static func unzip_file(source_file:String, target_path:String) -> bool:
	assert(DirAccess.dir_exists_absolute(target_path))
	var reader := ZIPReader.new()
	var err := reader.open(source_file)
	if err != OK:
		return false
	var dir_access = DirAccess.open(target_path)
	for file in reader.get_files():
		if file.get_extension():
			file = file.get_base_dir()
		dir_access.make_dir_recursive(file)
	for file in reader.get_files():
		if file.get_extension():
			var file_access = FileAccess.open(target_path.path_join(file),FileAccess.WRITE)
			if not file_access:
				push_error("unzip_file skip '%s'"%[file])
				continue
			file_access.store_buffer(reader.read_file(file))
			file_access.close()
	reader.close()
	return true
	
