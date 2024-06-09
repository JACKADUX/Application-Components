extends CanvasLayer

signal debug_draw(ua:CanvasItem)

@onready var rich_text_label = %RichTextLabel
@onready var canvas = %Draw

var _info := {}

func _ready():
	canvas.draw.connect(func():
		debug_draw.emit(canvas)
	)

func _process(delta):
	canvas.queue_redraw()

func clear():
	_info = {}
	update()
	
func info(key, text):
	_info[key] = text
	update()
	
func update():
	var str = JSON.stringify(_info, "\t")
	str = str.trim_prefix("{\n")
	str = str.trim_suffix("\n}")
	rich_text_label.text = str
	
