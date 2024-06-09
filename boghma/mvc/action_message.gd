# 用于向上传递命令请求
class_name ActionMessage extends BaseMessage

var _is_process:bool=false
func as_process(value:=true):
	_is_process = value
	return self
func is_process():
	return _is_process
	
#---------------------------------------------------------------------------------------------------
class BundleAction extends ActionMessage:
	# 可以将其他的action 作为 bundle 一起发送
	# undoredo只会记录一次
	var action_name:String=""
	var messages : Array = []
	func _to_string():
		return "BundleAction"
		
	func add_action(msg:ActionMessage):
		messages.append(msg)
		
	static func empty(name:String):
		return BundleAction.new([name, []])
	
#---------------------------------------------------------------------------------------------------
class Action extends ActionMessage:
	var data
	func _to_string():
		return "Action"


