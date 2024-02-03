@tool
class_name MographRadialContainer extends MographBaseContainer

@export var amount :float = 1
@export var radius :float = 100 

@export var start_angle:float = 0
@export var end_angle:float = 360
@export var offset_angle:float = 0

@export var align:= false

@export var overall_center_offset := Vector2(0.5,0.5)
@export var aling_z :int=0

func _process(delta):
	update(delta)

func update(delta):
	var count = get_child_count()
	if count<=1:
		return
	
	var z_each = aling_z
	var d_each = (end_angle-start_angle)/count
	var final_pos = func(index): return Transform2D(deg_to_rad(start_angle + d_each*index +offset_angle), Vector2.ZERO)*Vector2(radius*amount, 0)
	
	for child:Control in get_children():
		if not child is Control:
			continue 
		var index = child.get_index()
		child.pivot_offset = child.size*overall_center_offset
		child.position = final_pos.call(index) - child.pivot_offset
		child.z_index = z_each*index
		child.size = child.custom_minimum_size
		if align:
			child.rotation_degrees = start_angle + d_each*index +offset_angle
		else:
			child.rotation_degrees = 0
		child.scale = Vector2.ONE
		
	super(delta)
