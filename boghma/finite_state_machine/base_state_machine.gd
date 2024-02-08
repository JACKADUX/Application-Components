class_name BaseStateMachine extends Node

@export var agent:Node = self
var current_state:BaseState
var states := {}

func _process(delta):
	if not current_state: return
	current_state.update(delta)

func launch(state_index:int=0):
	current_state = states[state_index]
	current_state.enter()

func add_state(state_index:int, state:BaseState):
	states[state_index] = state
	state.state_machine = self

func remove_state(state_index:int):
	states[state_index].state_machine = null
	states.erase(state_index)
	
func transition_to(state_index:int, msg:={}):
	current_state.exit()
	current_state = states[state_index]
	current_state.enter(msg)
	
