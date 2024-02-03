@tool
class_name MographLinearContainer extends MographBaseContainer

enum LinearMode {EndPoint, PerStep}
@export var linear_mode:= LinearMode.EndPoint
@export var amount :float = 1

@export var align_position:= Vector2(100,0)
@export var align_rotation:float = 0
@export var align_scale := Vector2(1,1)
@export var overall_center_offset := Vector2(0.5,0.5)
@export var aling_z :int=0

@export var step_rotation:float = 0


func _process(delta):
	update(delta)
	
func update(delta):
	var count = get_child_count()
	if count<=1:
		return
	var rotate_each = align_rotation*amount
	var scale_each = func(index): return Vector2(pow(align_scale.x, index), pow(align_scale.y, index))
	var position_each = align_position*amount
	var z_each = aling_z
	if linear_mode == LinearMode.EndPoint:
		position_each /= count-1
		rotate_each /= count-1
		scale_each = func(index): 
			var _exp = index/float(count)
			return Vector2(pow(align_scale.x, _exp), pow(align_scale.y, _exp))
	
	
	var rotation_trans_call = func(index): return Transform2D(deg_to_rad(step_rotation*index), Vector2.ZERO)
	var pre_pos :=Vector2.ZERO
	
	for child:Control in get_children():
		if not child is Control:
			continue 
		var index = child.get_index()
		child.pivot_offset = child.size*overall_center_offset
		child.position = pre_pos - child.pivot_offset
		pre_pos += rotation_trans_call.call(index)*position_each
		child.z_index = z_each*index
		child.size = child.custom_minimum_size
		child.rotation_degrees = rotate_each*index + step_rotation*index
		child.scale = scale_each.call(index)
		
		apply_effector(child)

		














