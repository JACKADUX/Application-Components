@tool
class_name MographTargetEffector extends MographBaseEffector

@export var addition:= false

func apply_effect(node:Control):
	var field_result = get_field_result(node)
	
	var trans = get_node_real_global_transform(self)
	var node_trans = get_node_real_global_transform(node)
	var parent_trans = get_node_real_global_transform(node.get_parent()).affine_inverse()
	var rot = parent_trans*node_trans.looking_at(trans.origin)
	
	if addition:
		node.rotation += rot.get_rotation()*strength*field_result
	else:
		node.rotation = rot.get_rotation()*strength*field_result


	
