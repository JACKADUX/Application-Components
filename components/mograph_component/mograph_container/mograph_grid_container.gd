@tool
class_name MographGridContainer extends MographBaseContainer

enum GridMode {EndPoint, PerStep}
@export var grid_mode:= GridMode.EndPoint

@export var amount :float = 1
@export var grid_column:int= 3
@export var gird_size := Vector2(200,200)

@export var overall_center_offset := Vector2(0.5,0.5)
@export var aling_z :int=0

func _process(delta):
	update(delta)

func update(delta):
	var grid_column = max(grid_column, 1)
	var count = get_child_count()
	if count<=1:
		return
	
	var position_each = gird_size*amount
	var z_each = aling_z
	if grid_mode == GridMode.EndPoint:
		position_each /= count-1
		
	for child:Control in get_children():
		if not child is Control:
			continue 
		var index = child.get_index()
		var column = index%grid_column
		var row = index/grid_column
		child.pivot_offset = child.size*overall_center_offset
		child.position = position_each*Vector2(column, row) - child.pivot_offset
		child.z_index = z_each*index
		child.size = child.custom_minimum_size
		child.rotation_degrees = 0
		child.scale = Vector2.ONE
		
	super(delta)
