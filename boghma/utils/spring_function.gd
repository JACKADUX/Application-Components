class_name SpringFunction

var _spring:float = 500 # 1000
var _damp:float = 20 # 40

var _displacement :float=0
var _velocity :float=0

func set_velocity(value:float, spring:float=500, damp:float=20):
	_spring = spring
	_damp = damp
	_velocity = value
	
func get_displacment():
	return _displacement

func update(delta:float):
	var force = -_spring * _displacement - _damp*_velocity
	_velocity += force*delta
	_displacement += _velocity*delta

	
	
	
	
	
	
	
	
	
	
	
	
