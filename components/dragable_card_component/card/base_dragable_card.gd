class_name BaseDragableCard extends PanelContainer

@onready var label = $MarginContainer/HBoxContainer/Label

signal drag_started
signal drag_stoped

var dragable := false

#func _gui_input(event):
	#if event is InputEventMouseButton:
		#if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			#start_drag()

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

##
func _on_texture_rect_2_button_down():
	start_drag()
