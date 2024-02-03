class_name MographBaseEffector extends Node2D

@export var strength :float = 1
@export var enable_position:= false
@export var effect_position:=Vector2.ZERO
@export var enable_rotation:= false
@export var effect_rotation:float = 0
@export var enable_scale:= false
@export var effect_scale:=Vector2.ZERO
@export var fields :Array[MographBaseField] = []

func get_effect_position():
	return effect_position*strength

func get_effect_rotation():
	return effect_rotation*strength

func get_effect_scale():
	return effect_scale*strength
	

func get_field_result(node:Control):
	var field_result = 1
	for field:MographBaseField in fields:
		if not field or not field.visible:
			continue 
		field_result = field.get_field_result(node)
	return field_result
	
