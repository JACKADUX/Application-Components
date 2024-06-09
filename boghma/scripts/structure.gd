class_name Structure

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





