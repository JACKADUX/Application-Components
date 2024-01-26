extends PanelContainer

@onready var texture_rect_window_icon = %TextureRectWindowIcon
@onready var label_window_title = %LabelWindowTitle
@onready var btn_minimize_window = %BtnMinimizeWindow
@onready var btn_maxsimize_window = %BtnMaxsimizeWindow
@onready var btn_close_window = %BtnCloseWindow

#@onready var window_scaler = $WindowScaler

var _offset_position:Vector2i

func _ready():
	btn_minimize_window.pressed.connect(_on_window_minimize)
	btn_maxsimize_window.pressed.connect(_on_window_maxsimize)
	btn_close_window.pressed.connect(_on_close_window)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			#window_scaler.disable = false
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				var win_size = DisplayServer.window_get_size()*0.5
				DisplayServer.window_set_position(DisplayServer.mouse_get_position()-Vector2i(win_size.x,0))
			_offset_position = DisplayServer.window_get_position() -DisplayServer.mouse_get_position()
			
		elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			#window_scaler.disable = true
			pass
			
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			DisplayServer.window_set_position(DisplayServer.mouse_get_position()+_offset_position)


func _on_window_minimize():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	
func _on_window_maxsimize():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_close_window():
	get_tree().quit()
