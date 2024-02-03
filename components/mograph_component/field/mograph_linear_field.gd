@tool
class_name MographLinearField extends MographBaseField

@export var length :float = 100:
	set(value):
		length = value
		queue_redraw()

var _height = 50
var _color = Color.AQUA
var _width :float= 2

func get_field_result(node:Control) -> float:
	var node_trans = node.get_global_transform()
	var vx = get_global_transform().x
	var v1 = get_node_real_global_position(node)- global_position
	var shadow_length = vx.dot(v1)
	var field_result = remap(shadow_length, -length, length, 0, 1.0)
	field_result = clamp(field_result, 0, 1)
	return field_result

func _draw():
	var end = -length
	var start = length
	draw_line(Vector2(end, _height*0.5), Vector2(end, -_height*0.5), _color, _width)
	draw_line(Vector2(start, _height), Vector2(start, -_height), _color, _width)
	draw_line(Vector2(end, 0), Vector2(start, -0), _color, _width)
