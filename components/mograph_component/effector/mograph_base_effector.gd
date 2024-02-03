class_name MographBaseEffector extends Control

@export var strength :float = 1
@export var fields :Array[MographBaseField] = []

func get_node_real_global_transform(node:Control) -> Transform2D:
	var trans = node.get_global_transform()
	var pos = trans*node.pivot_offset
	trans.origin = pos
	return trans


func apply_effect(node:Control):
	pass


func get_field_result(node:Control):
	var field_result = 1
	for field:MographBaseField in fields:
		if not field or not field.visible:
			continue 
		## FIXME: 多个域叠加
		field_result = field.get_field_result(node)
	return field_result
	



	
