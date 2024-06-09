extends Node

var _factory:={}


enum ItemType {
	BaseItem,
}

#---------------------------------------------------------------------------------------------------
func _init():
	var simple_register := func(object:Object, type:ItemType):
		register(type, func():
			var instance = object.new()
			instance._type = type
			instance._type_string = ItemType.keys()[type]
			return instance 
		)
		
	simple_register.call(BaseItem, ItemType.BaseItem)
	

#---------------------------------------------------------------------------------------------------
func register(type:int, create_fn:Callable):
	_factory[type] = create_fn
	
#---------------------------------------------------------------------------------------------------
func unregister(type):
	if type in _factory:
		_factory.erase(type)
		
#---------------------------------------------------------------------------------------------------
func create(type:int):
	if _factory.get(type): 
		return _factory[type].call()


#---------------------------------------------------------------------------------------------------
func serialization(item:BaseItem):
	var item_datas = []
	for sub_item:BaseItem in item.iterate():
		var item_data = sub_item.serialization()
		item_datas.append(item_data)
	return item_datas

#---------------------------------------------------------------------------------------------------
func deserialization(item_datas:Array):
	var temp_map = {}
	var root_item:BaseItem
	for item_data in item_datas:
		var item :BaseItem = ItemFactory.create(item_data.type)
		temp_map[item_data.id] = item
		if not root_item:
			root_item = item
		var parent = temp_map.get(item_data.pid)
		if parent:
			parent.add_child(item)
		item.deserialization(item_data)
	return root_item
	
