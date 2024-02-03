@tool
class_name MographPlainEffector extends MographBaseEffector

enum TransformSpace {Nodes, Effector, ParentContainer}
@export var transform_space:=TransformSpace.Nodes

@export var enable_position:= false
@export var effect_position:=Vector2.ZERO
@export var enable_rotation:= false
@export var effect_rotation:float = 0
@export var enable_scale:= false
@export var effect_scale:=Vector2.ZERO
@export var enable_z_index:= false
@export var effect_z_index:int=0


func apply_effect(node:Control):
	var field_result = get_field_result(node)
	if enable_position:
		## NOTE: 注意这里要叠加相对位置
		node.position += get_effect_position(node)*field_result
	if enable_rotation:
		node.rotation_degrees += get_effect_rotation()*field_result
	if enable_scale:
		node.scale += get_effect_scale()*field_result
	if enable_z_index:
		node.z_index += get_effect_z_index()*field_result

func get_effect_z_index():
	return effect_z_index*strength

func get_effect_position(node:Control):
	match transform_space:
		TransformSpace.Nodes:
			var parent_trans_inverse = get_node_real_global_transform(node.get_parent()).affine_inverse()
			var trans:Transform2D = get_node_real_global_transform(node)
			var rel_trans = parent_trans_inverse*trans
			var lp = rel_trans*(effect_position*strength)
			lp -= rel_trans.origin
			return lp
		TransformSpace.Effector:
			var parent_trans_inverse = get_node_real_global_transform(node.get_parent()).affine_inverse()
			var trans:Transform2D = get_node_real_global_transform(self)
			var rel_trans = parent_trans_inverse*trans
			var lp = rel_trans*(effect_position*strength)
			lp -= rel_trans.origin
			return lp
		TransformSpace.ParentContainer:
			return (effect_position*strength)
	
func get_effect_rotation():
	return effect_rotation*strength

func get_effect_scale():
	return effect_scale*strength
	
