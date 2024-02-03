class_name MographBaseContainer extends Container

@export var effectors:Array[MographBaseEffector] = []


func update(delta:float):
	for child:Control in get_children():
		if not child is Control:
			continue 
		apply_effector(child)
		
func apply_effector(node:Control):
	for effector:MographBaseEffector in effectors:
		if not effector or not effector.visible:
			continue 
		effector.apply_effect(node)
		
