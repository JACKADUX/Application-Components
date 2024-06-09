class_name Factory

var _factory:={}

var custom_register:Callable
var custom_create:Callable

func register(type:int, create:Callable):
	_factory[type] = create
	
func unregister(type:int):
	if type in _factory:
		_factory.erase(type)

func create(type:int):
	if _factory.get(type): 
		return _factory[type].call()

