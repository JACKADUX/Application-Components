@tool
class_name MographContainer extends Container

enum Modes {Linear}
enum LinearMode {EndPoint, PerStep}
@export var mode:= Modes.Linear
@export var linear_mode:= LinearMode.EndPoint
@export var amount :float = 1

@export var align_position:= Vector2(100,0)
@export var align_rotation:float = 0
@export var align_scale := Vector2(1,1)
@export var overall_center_offset := Vector2(0.5,0.5)

@export var effectors:Array[MographBaseEffector] = []


func _process(delta):
	update()
	
func update():
	var count = get_child_count()
	if count<=1:
		return
	var rotate_each = align_rotation*amount
	var scale_each = func(index): return Vector2(pow(align_scale.x*amount, index), pow(align_scale.y*amount, index))
	var position_each = align_position*amount
	if linear_mode == LinearMode.EndPoint:
		position_each /= count-1
		rotate_each /= count-1
		scale_each = func(index): return Vector2(pow(align_scale.x*amount, index/float(count)), pow(align_scale.y*amount, index/float(count)))
		
	for child:Control in get_children():
		if not child is Control:
			continue 
		var index = child.get_index()
		#child.z_index = 0#int(z*index)
		child.pivot_offset = child.size*overall_center_offset
		child.position = position_each*index - child.pivot_offset
		child.size = child.custom_minimum_size
		child.rotation_degrees = rotate_each*index
		child.scale = scale_each.call(index)
		
		for effector:MographBaseEffector in effectors:
			if not effector or not effector.visible:
				continue 
			var field_result = effector.get_field_result(child)
			if effector.enable_position:
				child.position += effector.get_effect_position()*field_result
			if effector.enable_rotation:
				child.rotation_degrees += effector.get_effect_rotation()*field_result
			if effector.enable_scale:
				child.scale += effector.get_effect_scale()*field_result
	

















