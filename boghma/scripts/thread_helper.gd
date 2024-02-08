class_name ThreadHelper

var _thread := Thread.new()
var _funcs := []
var _end := false
var _holder :Node


func _init(holder:Node):
	_holder = holder
	_holder.tree_exited.connect(end)
	
func join_function(function:Callable, auto_start=true):
	_funcs.append(function)
	if auto_start:
		start()

func start():	
	assert(_holder, "holder can't be none")
	_end = false
	if not _thread.is_alive():
		if _thread.is_started():
			_thread.wait_to_finish()
		_thread.start(_start_thread)
		
func is_running():
	return _thread.is_alive()
	
func end():
	_end_thread()

func _start_thread():
	while true:
		if not _funcs or _end:
			break
		var function = _funcs.pop_front()
		if function and function is Callable:
			function.call()
		
func _end_thread():
	# !! 切记在强制中断thread时调用 end_thread, 否则可能会崩溃
	_end = true
	_funcs = []
	if _thread.is_started():
		_thread.wait_to_finish()

