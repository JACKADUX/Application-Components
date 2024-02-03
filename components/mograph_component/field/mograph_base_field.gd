class_name MographBaseField extends Control


func get_node_real_global_position(node:Control):
	return node.get_global_transform()*node.pivot_offset

func get_field_result(node:Control) -> float:
	return 1
