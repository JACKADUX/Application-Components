extends Node

signal cursor_index_changed(index)

@export var window_id:int = 0  ## Window index
@export var activate:bool = true:  ## Set false if you want to stop process 
	set(value):
		activate = value
		set_process(value)
@export var min_size := Vector2i(260, 100)  ## Min window size
@export var detect_state_gap :int = 2   ## distance (pixcel) to window border on detect state 
@export var other_state_gap :int = 16   ## distance (pixcel) to window border on other state
@export var change_cursor := true   ## set false if you don't want to change cursor
@export var only_change_on_windowed_mode:= true   ## set false if you want to change scale on FULLSCREEN mode

const CURSOR_LIST = [ DisplayServer.CURSOR_ARROW, 
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
enum State {Detect, Wait, Resize}
var state = State.Detect

var _start_window_rect:Rect2i
var _resize_index :int = 0

func _ready():
	activate = activate

func _process(delta):
	if only_change_on_windowed_mode and DisplayServer.window_get_mode(window_id) != DisplayServer.WINDOW_MODE_WINDOWED:
		return 
	var _mp = DisplayServer.mouse_get_position()
	var _window_rect = get_window_rect(window_id)
	var gap = detect_state_gap if state == State.Detect else other_state_gap
	var _inside_rect = _window_rect.grow(-gap)
	
	if state != State.Resize:
		_resize_index = get_grid_index(_window_rect, _mp, gap)
	cursor_index_changed.emit(_resize_index)
	if change_cursor:
		DisplayServer.cursor_set_shape(CURSOR_LIST[_resize_index])
	
	match state:
		State.Detect:
			if _window_rect.has_point(_mp) and not _inside_rect.has_point(_mp):
				state = State.Wait				
		State.Wait:
			if _window_rect.has_point(_mp) and not _inside_rect.has_point(_mp):
				_start_window_rect = _window_rect
			else:
				state = State.Detect
		State.Resize:
			resize_window(_start_window_rect, _mp, _resize_index, min_size)

## Interface
func is_waiting_resize():
	return state == State.Wait

func is_resizing():
	return state == State.Resize

func start_resize():
	if state == State.Wait:
		state = State.Resize
	
func stop_resize():
	if state == State.Resize:
		state = State.Detect

func resize_window(start_rect:Rect2i, point:Vector2i, index:int, min_size:Vector2, window_id:int=0):
	var rect = Rect2i(resize_rect(start_rect, point, index, min_size))
	DisplayServer.window_set_position(rect.position, window_id)
	DisplayServer.window_set_size(rect.size, window_id)

## Statics
static func get_grid_index(rect:Rect2, point:Vector2, gap:float):
	var local_mp = point-rect.position
	var w = rect.size.x
	var h = rect.size.y
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
	return index

static func resize_rect(rect:Rect2, point:Vector2, index:int, min_size:=Vector2.ZERO):
	var start = rect.position
	var end = rect.end
	match index:
		1:
			start = point
		2:
			start.y = point.y
		3:
			start.y = point.y
			end.x = point.x
		4:
			start.x = point.x
		6:
			end.x = point.x
		7: 
			start.x = point.x
			end.y = point.y
		8:
			end.y = point.y
		9:
			end = point
	var new_win_size = end -start
	if new_win_size.x < min_size.x:
		if index in [1, 4, 7]:
			start.x = end.x-min_size[0]
	if new_win_size.y < min_size.y:
		if index in [1, 2, 3]:
			start.y = end.y-min_size[1]
	new_win_size.x = max(min_size[0], new_win_size.x)
	new_win_size.y = max(min_size[1], new_win_size.y)
	return Rect2(start, new_win_size)
	
static func get_window_rect(window_id:int=0):
	return Rect2i(DisplayServer.window_get_position(window_id), DisplayServer.window_get_size(window_id))

	

