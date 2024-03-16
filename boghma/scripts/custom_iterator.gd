class_name CustomIterator

class Enumerate:
	var array
	var index
	
	func _init(array:Array):
		self.array = array

	func _iter_init(arg):
		index = 0
		return array

	func _iter_next(arg):
		index += 1
		return index < array.size()

	func _iter_get(arg):
		return {"index":index, "value":array[index]}



class DirectoryIterator:
	var ori_directory :String
	var current :String
	var stack := []
	var current_dir:DirAccess
		
	func _init(directory:String):
		ori_directory = directory

	func _iter_init(arg):
		assert(ori_directory and DirAccess.dir_exists_absolute(ori_directory), 
				"not valid directory: '%s'"% ori_directory)
		current = ori_directory
		current_dir = DirAccess.open(ori_directory)
		current_dir.list_dir_begin()
		stack = []
		return true

	func _iter_next(arg):
		var file_name = current_dir.get_next()
		if file_name == "":
			while true:
				if not stack:
					return false
				current_dir.list_dir_end()
				current_dir = stack.pop_back()
				file_name = current_dir.get_next()
				if file_name:
					break
		current = current_dir.get_current_dir() +"/"+ file_name
		if current_dir.current_is_dir():
			stack.append(current_dir)
			current_dir = DirAccess.open(current)
			current_dir.list_dir_begin()

		return true

	func _iter_get(arg):
		return current


class TreeStructureIterator:
	var current
	var ori
	
	func _init(current:TreeItem):
		self.ori = current
		self.current = current

	func _iter_init(arg):
		current = ori
		return current

	func _iter_next(arg):
		var down = current.get_first_child()
		if down:
			current = down
			return true
		var next = current.get_next()
		if next:
			current = next
			return true
		while true:
			var parent = current.get_parent()
			if not parent:
				return false
			next = parent.get_next()
			if next:
				current = next
				return true
			current = parent
		return false

	func _iter_get(arg):
		return current
		
