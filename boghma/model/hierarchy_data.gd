class_name HierarchyData extends Resource

@export var _parent:HierarchyData
@export var _children:Array[HierarchyData]

#region Hierarchy
func get_parent() -> HierarchyData:
	return _parent

func add_child(child: HierarchyData) -> Error:
	if child in _children:
		return FAILED
	if child.get_parent():
		return FAILED
	_children.append(child)
	child._parent = self
	return OK
	
func remove_child(child: HierarchyData) -> Error:
	if child not in _children:
		return FAILED
	_children.erase(child)
	child._parent = null
	return OK

func get_index() -> int:
	if not _parent:
		return -1
	return _parent._children.find(self)

func get_children() -> Array:
	return _children.duplicate()

func get_child_count() -> int:
	return _children.size()

func get_child(index:int):
	return _children[index]

func move_child(child: HierarchyData, to_index: int) -> Error:
	if child not in _children:
		return FAILED
	var current_index = _children.find(child)
	if current_index == -1 or current_index == to_index:
		return FAILED
	_children.erase(child)
	if to_index >= _children.size():
		_children.append(child)
	else:
		_children.insert(to_index, child)
	return OK

func iterate():
	return Iterator.new(self)
	
#endregion
class Iterator:
	var _current:HierarchyData
	var ori:HierarchyData
	
	func _init(current):
		_current = current
		ori = current

	func _iter_init(arg):
		_current = ori
		return _current
	
	func get_next(obj:HierarchyData):
		var parent = obj.get_parent()
		if not parent:
			return 
		var count = parent.get_child_count()
		var index = obj.get_index()+1 
		if index < count:
			return parent.get_child(index)
	
	func _iter_next(arg):
		if _current.get_child_count() >0:
			_current = _current.get_child(0)
			return true
		var next = get_next(_current)
		if next:
			_current = next
			return true
		while true:
			var parent = _current.get_parent()
			if not parent:
				return false
			next = get_next(parent)
			if next:
				_current = next
				return true
			_current = parent
		return false

	func _iter_get(arg):
		return _current
		
