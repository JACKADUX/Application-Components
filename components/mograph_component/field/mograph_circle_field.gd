@tool
class_name MographCircleField extends MographBaseField


@export var radius :float = 100:
	set(value):
		radius = value
		queue_redraw()
		
var _color = Color.AQUA
var _width :float= 2


func get_field_result(node:Control) -> float:
	var v1 = get_node_real_global_position(node)- global_position
	var field_result = remap(v1.length(), radius, 0, 0, 1.0)
	field_result = clamp(field_result, 0, 1)
	return field_result


func _draw():
	if not Engine.is_editor_hint():
		return
	draw_arc(Vector2.ZERO, radius, 0, PI*2, 32, _color, _width)
