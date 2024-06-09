class_name Utils

#---------------------------------------------------------------------------------------------------
static func file_dialog(title:String="Files", filter=[], mode=DisplayServer.FILE_DIALOG_MODE_OPEN_FILE):
	var files = []
	var _on_folder_selected = func(status:bool, selected_paths:PackedStringArray, _selected_filter_index:int):
		if not status:
			return
		files.append_array(selected_paths)
	DisplayServer.file_dialog_show(title,"","",false,
								mode,
								filter,
								_on_folder_selected)
	return files
