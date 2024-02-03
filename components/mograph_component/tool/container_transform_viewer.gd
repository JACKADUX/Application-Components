@tool
extends Control

@export var mograph_container:MographBaseContainer


func get_node_real_global_transform(node:Control) -> Transform2D:
	var trans = node.get_global_transform()
	var pos = trans*node.pivot_offset
	trans.origin = pos
	return trans

func _process(delta):
	queue_redraw()

func draw_arrow(pos, dir:Vector2, length:float=200, width:float=1, color:= Color.AZURE):
	var to = pos+dir*length
	draw_line(pos, to, color, width, true)
	draw_line(to, to-dir.rotated(deg_to_rad(45))*length*0.1,color, width, true)
	draw_line(to, to-dir.rotated(deg_to_rad(-45))*length*0.1, color, width, true)

func draw_trans(trans:Transform2D, length:float=200, width:float= 1):
	draw_arrow(trans.origin, trans.x, length, width, Color.RED)
	draw_arrow(trans.origin, trans.y, length, width, Color.GREEN_YELLOW)

func _draw():
	if not mograph_container:
		return 
	var g_trans = get_node_real_global_transform(self)
	var trans = get_node_real_global_transform(mograph_container)
	draw_trans(g_trans.affine_inverse()*trans,100)
	for child in mograph_container.get_children():
		trans = get_node_real_global_transform(child)
		draw_trans(g_trans.affine_inverse()*trans,50)
	

