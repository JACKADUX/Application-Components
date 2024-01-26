extends Node

@export var window_id:int = 0
@export var maxsimize_position_compensatory:=Vector2i(0,2)
@export var maxsimize_size_compensatory:=Vector2i(0,48)
var _previous_rect:Rect2i
var _maxsimized := false  ## 无边框模式maxsimize会有一些问题，所以需要额外的变量来记录状态

func is_fullscreen():
	return DisplayServer.window_get_mode(window_id) == DisplayServer.WINDOW_MODE_FULLSCREEN

func is_maxsimized():
	if not ProjectSettings.get("display/window/size/borderless"):
		return DisplayServer.window_get_mode(window_id) == DisplayServer.WINDOW_MODE_MAXIMIZED
	else:
		return _maxsimized

func set_minimized():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED, window_id)

func set_maxsimized():
	_previous_rect = get_window_rect(window_id)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED, window_id)
	if ProjectSettings.get("display/window/size/borderless"):
		var rect = get_window_rect(window_id)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, window_id)
		DisplayServer.window_set_position(rect.position-maxsimize_position_compensatory, window_id)
		DisplayServer.window_set_size(rect.size-maxsimize_size_compensatory, window_id)
		_maxsimized = true
	
func set_fullscreen():
	_previous_rect = get_window_rect(window_id)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, window_id)

func set_windowed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, window_id)
	if ProjectSettings.get("display/window/size/borderless"):
		_maxsimized = false
	if _previous_rect:
		DisplayServer.window_set_position(_previous_rect.position, window_id)
		DisplayServer.window_set_size(_previous_rect.size, window_id)
		
func toggle_fullscreen():
	if is_fullscreen():
		set_windowed()
	else:
		set_fullscreen()

func toggle_maxsimized():
	if is_maxsimized():
		set_windowed()
	else:	
		set_maxsimized()

func quit():
	get_tree().quit()

func get_window_rect(window_id:int):
	return Rect2i(DisplayServer.window_get_position(window_id), DisplayServer.window_get_size(window_id))

