extends Node

@export var enable:bool = true
@export var MinSize := Vector2i(260, 100)

var disable := false
enum State {Detect, Wait, Drag}
var state = State.Detect

var mp 
var window_rect
var inside_rect
var cursor_index

var start_window_rect
var cursor_list = [ DisplayServer.CURSOR_ARROW, 
					DisplayServer.CURSOR_FDIAGSIZE, # 1
					DisplayServer.CURSOR_VSIZE,
					DisplayServer.CURSOR_BDIAGSIZE,
					DisplayServer.CURSOR_HSIZE,
					DisplayServer.CURSOR_ARROW, #5
					DisplayServer.CURSOR_HSIZE,
					DisplayServer.CURSOR_BDIAGSIZE, # 7
					DisplayServer.CURSOR_VSIZE,
					DisplayServer.CURSOR_FDIAGSIZE,
					]

func _input(event):
	if disable:
		return 
	if not enable :
		return
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		return 
	match state:
		State.Detect:
			update_data()
			detect_window_edge(event)
		State.Wait:
			update_data()
			wait_window_drag(event)
		State.Drag:
			drag_window(event)

func update_data():
	mp = DisplayServer.mouse_get_position()
	window_rect = Rect2i(DisplayServer.window_get_position(), DisplayServer.window_get_size())
	var gap = get_grow_size()  # -2 or -16
	inside_rect = window_rect.grow(-gap)

	# 
	var local_mp = mp-window_rect.position
	var w = window_rect.size.x
	var h = window_rect.size.y
	var x = local_mp.x
	var y = local_mp.y
	var index = 0
	if y<gap:
		if x < gap:
			index = 1
		elif gap <= x and x < w-gap:
			index = 2
		elif w-gap <= x:
			index = 3
	elif gap <= y and y < h-gap:
		if x < gap:
			index = 4
		elif gap <= x and x < w-gap:
			index = 5
		elif w-gap <= x:
			index = 6
	elif h-gap <= y:
		if x < gap:
			index = 7
		elif gap <= x and x < w-gap:
			index = 8
		elif w-gap <= x:
			index = 9
	cursor_index = index
		
func get_grow_size():
	match state:
		State.Detect:
			return 2
		State.Wait:
			return 16
		State.Drag:
			return 16
	return 0

func drag_window(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			start_window_rect = window_rect
		elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			state = State.Wait
	if event is InputEventMouseMotion:
		DisplayServer.cursor_set_shape(cursor_list[cursor_index])
		var current_mp = DisplayServer.mouse_get_position()
		var start = start_window_rect.position
		var end = start_window_rect.end

		match cursor_index:
			1:
				start = current_mp
			2:
				start.y = current_mp.y
			3:
				start.y = current_mp.y
				end.x = current_mp.x
			4:
				start.x = current_mp.x
			6:
				end.x = current_mp.x
			7: 
				start.x = current_mp.x
				end.y = current_mp.y
			8:
				end.y = current_mp.y
			9:
				end = current_mp
				
		
		var new_win_size = end -start
		if new_win_size.x < MinSize.x:
			if cursor_index in [1, 4, 7]:
				start.x = end.x-MinSize[0]
		if new_win_size.y < MinSize.y:
			if cursor_index in [1, 2, 3]:
				start.y = end.y-MinSize[1]
		new_win_size.x = max(MinSize[0], new_win_size.x)
		new_win_size.y = max(MinSize[1], new_win_size.y)
		DisplayServer.window_set_position(start)
		DisplayServer.window_set_size(new_win_size)
		
	get_viewport().set_input_as_handled()	
	
func wait_window_drag(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if window_rect.has_point(mp) and not inside_rect.has_point(mp):
				DisplayServer.cursor_set_shape(cursor_list[cursor_index])
				state = State.Drag
				drag_window(event)
				
	if event is InputEventMouseMotion:
		if window_rect.has_point(mp) and not inside_rect.has_point(mp):
			DisplayServer.cursor_set_shape(cursor_list[cursor_index])
		else:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
			state = State.Detect
	get_viewport().set_input_as_handled()	
		
func detect_window_edge(event):
	if event is InputEventMouseMotion:
		if event.is_pressed():
			return 
		if window_rect.has_point(mp) and not inside_rect.has_point(mp):
			DisplayServer.cursor_set_shape(cursor_list[cursor_index])
			get_viewport().set_input_as_handled()
			state = State.Wait
		
