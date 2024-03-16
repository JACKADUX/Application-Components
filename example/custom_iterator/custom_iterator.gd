extends Control

func _ready():
	iterate_tree()

func iterate_tree():
	var tree = Tree.new()
	add_child(tree)
	var root = tree.create_item()
	root.set_text(0, "root")
	tree.hide_root = true
	for i in range(10):
		var child = tree.create_item(root)
		child.set_text(0, "child"+str(i))
		for j in range(10):
			var subchild = tree.create_item(child)
			subchild.set_text(0, "Subchild"+str(j))
	
	for f in CustomIterator.TreeStructureIterator.new(root):
		var n = f.get_text(0)
		if n.begins_with("S"):
			print("\t", n)
		else:
			print(n)

func iterate_directory():
	var path = r"G:\obsidian"
	for f in CustomIterator.DirectoryIterator.new(path):
		print(f)

func enumerate_array():
	var iterator = CustomIterator.Enumerate.new([123,2,3,4])
	for data in iterator:
		print(data.index, "-",data.value)

	for data in iterator:
		print(data.index, "-",data.value)

