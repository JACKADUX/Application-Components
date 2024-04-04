class_name UniformData extends HierarchyData

@export var _id:String = ""
@export var _type:int = 0
@export var _type_string:String = ""

func _to_string() -> String:
	return "<#%s>:%s"%[get_type_string(), get_id()] 

func get_id():
	if not _id:
		_id = str(get_instance_id())
	return _id

func get_type():
	return _type

func get_type_string():
	return _type_string	



