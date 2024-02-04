class_name BaseDragableCard extends PanelContainer

signal drag_started
signal drag_stoped

var dragable := false

## Interface
func start_drag():
	dragable = true
	modulate.a = 0.9 
	drag_started.emit()
	
func stop_drag():
	dragable = false
	modulate.a = 1
	drag_stoped.emit()
	
func is_dragable():
	return dragable

