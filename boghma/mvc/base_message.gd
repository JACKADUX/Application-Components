class_name BaseMessage


# signal message_sended(msg:BaseMessage)
# #---------------------------------------------------------------------------------------------------
# func handle_message(msg:BaseMessage):
# 	pass
# #---------------------------------------------------------------------------------------------------
# func send_message(msg:BaseMessage):
# 	message_sended.emit(msg)


var _kwargs := {}

func _init(args:Array, kwargs:={}):
	var index = 0
	for arg in self.get_property_list():
		if (arg.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		if arg.name.begins_with("_"):
			continue
		self.set(arg.name, args[index])
		assert(self.get(arg.name) == args[index],
				"参数类型必须是一致的，否则 set 会无效 。Array[String] ！= Array" 
				)
		index += 1
	
	if index < args.size():
		push_error("not all args being used! %d/%d"%[index, args.size()])
	_kwargs = kwargs
	
func get_kwargs(key:String):
	# 保证调用时这个值一定存在，否则会报错
	return _kwargs[key]


func _to_string():
	return "< BaseMessage#%d >"%get_instance_id()



static func connect_message_handler(sender, handler):
	assert(handler.has_method("handle_message"))
	sender.message_sended.connect(func(msg:BaseMessage):
		#prints(sender, "[Send]:", msg, "[To]:", handler)
		handler.handle_message(msg)
	)
