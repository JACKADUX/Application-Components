@tool
class_name MographDelayEffector extends Control

@export var enable_position := true
@export var enable_rotation := true
@export var enable_scale := true

@export var spring:float = 500 # 1000
@export var damp:float = 20 # 40

@export var debug :float

var _displacement :float=0
var _velocity :float=0
var _rand :float = 0

@export var mograph_grid_container:Node

var _pre :Vector2

func set_velocity(value:float):
	_velocity = value
	
func get_displacment():
	return _displacement

func _delay_update(delta:float):
	var force = -spring * _displacement - damp*_velocity
	_velocity += force*delta
	_displacement += _velocity*delta

#func _input(event):
	#if event.is_pressed():
		#_velocity = 1000
		#mograph_grid_container.align_position = Vector2(randf_range(-100,100), randf_range(-100,100))
		#_pre = mograph_grid_container.align_position
#func _process(delta):
	#_delay_update(delta)
	##mograph_grid_container.align_position = _pre + Vector2(0, _displacement)

	
	
	
	
	
	
	
	
	
	
	
	
