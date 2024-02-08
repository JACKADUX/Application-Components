class_name BaseState extends RefCounted

var state_machine:BaseStateMachine
var agent:Node:
	get: return state_machine.agent


func enter(msg:={}):
	pass
	
func exit():
	pass

func update(delta:float):
	pass

func transition_to(state_index:int, msg:={}):
	state_machine.transition_to(state_index, msg)
