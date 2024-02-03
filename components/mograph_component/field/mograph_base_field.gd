class_name MographBaseField extends Node2D


func get_node_real_global_position(node:Control):
	return node.get_global_transform()*node.pivot_offset

func get_field_result(node:Control) -> float:
	return 1
