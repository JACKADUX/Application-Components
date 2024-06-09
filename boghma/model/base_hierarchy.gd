class_name BaseHierarchy

var _parent:BaseHierarchy=null
var _children:Array = []

enum DragDrop {
	BEFORE=-1,
	UNDER=0,
	AFTER=1,
	UNDER_FIRST=2,
}

#region Hierarchy
func path_to_root(revered:=false, inclued_item:=true) -> Array:
	# 默认 [self -> root] , reversed [root, self]
	var path_list = []
	if inclued_item:
		path_list = [self]
	var parent = get_parent()
	while parent:
		path_list.append(parent)
		parent = parent.get_parent()
	if revered:
		path_list.reverse()
	return path_list

func is_ancestor_of(data:BaseHierarchy) -> bool:
	return self in data.path_to_root(false, false)

func get_parent() -> BaseHierarchy:
	return _parent

func add_child(child: BaseHierarchy) -> Error:
	if child in _children:
		return FAILED
	if child.get_parent():
		return FAILED
	if child.is_ancestor_of(self):
		return FAILED
	_children.append(child)
	child._parent = self
	return OK
	
func remove_child(child: BaseHierarchy) -> Error:
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

func move_child(child: BaseHierarchy, to_index: int) -> Error:
	if child not in _children:
		return FAILED
	var current_index = _children.find(child)
	if current_index == -1 or current_index == to_index:
		return FAILED
	_children.erase(child)
	to_index = clamp(to_index, 0, _children.size())
	if to_index >= _children.size():
		_children.append(child)
	else:
		_children.insert(to_index, child)
	return OK

func move_before(other:BaseHierarchy) -> Error:
	if other == self:
		return FAILED
	var other_parent := other.get_parent()
	assert(other_parent, "other_parent 必须存在才能用这个方法")
	if not _parent:
		other_parent.add_child(self)
	elif _parent != other_parent:
		_parent.remove_child(self)
		other_parent.add_child(self)
	if get_index() != other.get_index():
		other_parent.move_child(self, other.get_index())
	return OK
	
func move_after(other:BaseHierarchy) -> Error:
	if other == self:
		return FAILED
	var other_parent := other.get_parent()
	assert(other_parent, "other_parent 必须存在才能用这个方法")
	if not _parent:
		other_parent.add_child(self)
	elif _parent != other_parent:
		_parent.remove_child(self)
		other_parent.add_child(self)
	var other_index = other.get_index()
	if get_index() < other_index:
		other_parent.move_child(self, other.get_index())
	else:
		other_parent.move_child(self, other.get_index()+1)
	return OK
		
func drag_to(drop:BaseHierarchy, section:DragDrop) -> Error:
	if drop == self:
		return FAILED
	match section:
		DragDrop.BEFORE:
			return move_before(drop)
		DragDrop.UNDER: 
			var parent = get_parent()
			if parent:
				parent.remove_child(self)
			drop.add_child(self)
			return OK
		DragDrop.AFTER:
			return move_after(drop)
		DragDrop.UNDER_FIRST:
			var parent = get_parent()
			if parent:
				parent.remove_child(self)
			drop.add_child(self)
			drop.move_child(self, 0)
			return OK
	return FAILED 

func get_prev() -> BaseHierarchy:
	var index = get_index()-1
	if index >= 0:
		return get_parent().get_child(index)
	return null

func get_next() -> BaseHierarchy:
	var index = get_index()+1
	if index < get_parent().get_child_count():
		return get_parent().get_child(index)
	return null
		
func iterate():
	return Iterator.new(self)

#endregion
class Iterator:
	var _current:BaseHierarchy
	var ori:BaseHierarchy
	
	func _init(current):
		_current = current
		ori = current

	func _iter_init(arg):
		_current = ori
		return _current
	
	func get_next(obj:BaseHierarchy):
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
		
static func print_tree(element:BaseHierarchy, level:int=0):
	print("\t".repeat(level), element)
	for child in element.get_children():
		print_tree(child, level+1)

##==================================================================================================
static func undoredo_add(undoredo:UndoRedo, item, parent, action_name:="Add"):
	undoredo.create_action(action_name)
	undoredo.add_do_method(func():
		parent.add_child(item)
	)
	undoredo.add_do_reference(item)
	undoredo.add_undo_method(func():
		parent.remove_child(item)
	)
	undoredo.commit_action()
	return item


static func undoredo_remove(undoredo:UndoRedo, item, action_name:="Remove"):
	var parent = item.get_parent()
	if not parent:
		return 
	undoredo.create_action(action_name)
	undoredo.add_do_method(func():
		parent.remove_child(item)
	)
	undoredo.add_undo_method(func():
		parent.add_child(item)
	)
	undoredo.add_undo_reference(item)
	undoredo.commit_action()


static func undoredo_drag(undoredo:UndoRedo, drags:Array, drop, drop_mode:BaseHierarchy.DragDrop, action_name:="ChangeHierarchy"):
	undoredo.create_action(action_name)
	# undo
	for item in drags:
		var _drop = item.get_prev()
		var _mode = BaseHierarchy.DragDrop.AFTER
		if not _drop:
			_drop = item.get_parent()
			_mode = BaseHierarchy.DragDrop.UNDER_FIRST
		undoredo.add_undo_method(item.drag_to.bind(_drop, _mode))
	# do
	for item in drags:
		var _drop = drop
		var _mode = drop_mode
		if item.get_index() != 0:
			_drop = drags[item.get_index()-1]
			_mode = BaseHierarchy.DragDrop.AFTER 
		undoredo.add_do_method(item.drag_to.bind(_drop, _mode))
	undoredo.commit_action()


