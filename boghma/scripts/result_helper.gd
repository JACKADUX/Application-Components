class_name ResultHelper

signal any_result
signal successed
signal failed
signal error_occurred

var state := 0

func _init():
	successed.connect(emit_signal.bind("any_result"))
	failed.connect(emit_signal.bind("any_result"))
	error_occurred.connect(emit_signal.bind("any_result"))

func is_nothing_happend():
	return state == 0
	
func is_successed():
	return state == 1
	
func is_failed():
	return state == 2
	
func is_error_occurred():
	return state == 3

func success():
	state = 1
	successed.emit()

func fail():
	state = 2
	failed.emit()
	
func error():
	state = 3
	error_occurred.emit()
