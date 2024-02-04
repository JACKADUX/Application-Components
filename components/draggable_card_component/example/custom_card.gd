extends BaseDragableCard

@onready var drag_handle_texture_rect = $MarginContainer2/HBoxContainer/DragHandleTextureRect
@onready var label = $MarginContainer2/HBoxContainer/Label

func _ready():
	drag_handle_texture_rect.button_down.connect(start_drag)

func set_label(value:String):
	label.text = value
