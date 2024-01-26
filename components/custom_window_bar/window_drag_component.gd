extends Node

signal drag_started
signal drag_stoped

@export var window_id:int = 0

var _offset_position:Vector2i

func _ready():
	stop_drag()

func _process(delta):
	DisplayServer.window_set_position(DisplayServer.mouse_get_position()+_offset_position, window_id)

## Interface
func start_drag():
	set_process(true)
	_offset_position = DisplayServer.window_get_position(window_id) -DisplayServer.mouse_get_position()
	drag_started.emit()
	
func stop_drag():
	set_process(false)
	_offset_position = Vector2.ZERO
	drag_stoped.emit()
	
func is_dragging():
	return is_processing()
