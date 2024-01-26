extends PanelContainer
"""
## NOTE:
1.this three setting must be true if you want a transparent background!
	ProjectSettings.set("display/window/size/borderless", true)
	ProjectSettings.set("display/window/size/transparent", true)
	ProjectSettings.set("rendering/viewport/transparent_background", true)

2.top level of container grow direction needs to be Right and Bottom
"""

@export var window_min_size:= Vector2i(300,100):
	set(value):
		window_min_size = value
		if is_node_ready():
			window_resize_component.min_size = window_min_size

@onready var texture_rect_window_icon = %TextureRectWindowIcon
@onready var label_window_title = %LabelWindowTitle
@onready var btn_minimize_window = %BtnMinimizeWindow
@onready var btn_maxsimize_window = %BtnMaxsimizeWindow
@onready var btn_close_window = %BtnCloseWindow

@onready var window_state_component = %WindowStateComponent
@onready var window_drag_component = %WindowDragComponent
@onready var window_resize_component = %WindowResizeComponent

func _ready():
	window_min_size = window_min_size
	btn_minimize_window.pressed.connect(window_state_component.set_minimized)
	btn_maxsimize_window.pressed.connect(window_state_component.toggle_maxsimized)
	btn_close_window.pressed.connect(window_state_component.quit)
	
	window_drag_component.drag_started.connect(func(): window_resize_component.activate = false )
	window_drag_component.drag_stoped.connect(func(): window_resize_component.activate = true )

func _process(delta):
	var is_resize = window_resize_component.is_waiting_resize() or window_resize_component.is_resizing()
	btn_minimize_window.disabled = is_resize
	btn_maxsimize_window.disabled = is_resize
	btn_close_window.disabled = is_resize

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if window_resize_component.is_waiting_resize():
				window_resize_component.start_resize()
				get_viewport().set_input_as_handled()
		elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if window_resize_component.is_resizing():
				window_resize_component.stop_resize()
				get_viewport().set_input_as_handled()
				
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if window_resize_component.is_resizing():
				get_viewport().set_input_as_handled()
			
func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		pass
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		if window_resize_component.is_resizing():
			window_resize_component.stop_resize()
		if window_drag_component.is_dragging():
			window_drag_component.stop_drag()
			
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				pass
			elif window_drag_component.is_dragging():
				window_drag_component.stop_drag()
		
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if window_state_component.is_maxsimized():
				# 全屏状态下拖拽会缩小窗口
				window_state_component.set_windowed()
				var win_size = DisplayServer.window_get_size()*0.5
				DisplayServer.window_set_position(DisplayServer.mouse_get_position()-Vector2i(win_size.x,20))
			if not window_drag_component.is_dragging():
				window_drag_component.start_drag()
			
			
			
			

