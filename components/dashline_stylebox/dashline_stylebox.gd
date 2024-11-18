class_name DashLineStyleBox extends StyleBox

@export var corner_radius :int = 80
@export var width :int = 6
@export var corner_point_count :int = 20
@export var color := Color.WHITE

@export var dash_length :float = 50
@export var dash_skip_length :float = 20
@export var dash_sub_step :int = 8
@export var round_edge := true

var _cache :Rect2
var final_dash_lines := []

func update(rect:Rect2):
	dash_length = max(dash_length, 0)
	dash_skip_length = max(dash_skip_length, 0)
	dash_sub_step = max(dash_sub_step, 2)
	
	corner_radius = min(rect.size[rect.size.min_axis_index()]*0.5, corner_radius)
	var points = get_round_rect(rect, corner_radius, corner_point_count)
	final_dash_lines = polyline_to_dash(points, dash_length, dash_skip_length, dash_sub_step)
	
func _draw(rid: RID, rect: Rect2):
	if _cache != rect:
		_cache = rect
		update(rect)
	
	var rad = round(width*0.5)
	for points in final_dash_lines:
		RenderingServer.canvas_item_add_polyline(rid, points, PackedColorArray([color]), width, true)
		if round_edge:
			RenderingServer.canvas_item_add_circle(rid, points[0], rad, color, true)
			RenderingServer.canvas_item_add_circle(rid, points[-1], rad, color, true)
	
static func _get_corner_round_points(radius:float, count:int=8) -> PackedVector2Array:
	var delta = PI*0.5/count
	var round_points := PackedVector2Array()
	for i in range(count+1):
		var ri = count-i
		var pos = Vector2(radius * cos(delta*i+ PI), radius * sin(delta*i+ PI))
		round_points.append(pos)
	return round_points

static func get_round_rect(rect:Rect2, radius:int, round_count:int=16) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.append(Vector2.ZERO)
	points.append(Vector2(rect.size.x, 0))
	points.append(rect.size)
	points.append(Vector2(0, rect.size.y))
	#
	var round_points = _get_corner_round_points(radius, round_count)
	
	# bevel
	for i in range(4):
		var index = 3-i
		var prev = points[index-1]
		var curr = points[index]
		var next = points[(index+1)%points.size()]
		var v_prev = (prev-curr).normalized()*radius
		var v_next = (next-curr).normalized()*radius
		points[index] = curr+v_prev
		
		var offset_matrix = Transform2D().rotated(PI*0.5*index).translated(curr+v_prev+v_next)
		var rps :PackedVector2Array = offset_matrix*round_points
		rps.remove_at(0)
		for pindex in rps.size():
			var rev_i = rps.size()-1-pindex
			points.insert(index+1, rps[rev_i].round())
	points.append(points[0])
	return points

static func polyline_to_dash(points:PackedVector2Array, step:float, skip_step:float, sub_step_count:int=8) -> Array[PackedVector2Array]:
	var curve = Curve2D.new()
	for p in points:
		curve.add_point(p)
	var lenth = curve.get_baked_length()
	var dash_lines :Array[PackedVector2Array]= []
	var total = 0
	var sub_step = step/sub_step_count
	
	# NOTE: 补偿尾端的一段距离到整个长度
	var seg = step + skip_step
	var count = round(lenth/seg)
	step = (lenth/count)*(step/seg)
	skip_step = (lenth/count)*(skip_step/seg)
	while true:
		if total >= lenth:
			break
		var end = total+step
		var temp := PackedVector2Array()
		for i in range(sub_step_count):
			temp.append(curve.sample_baked(total+i*sub_step))
		dash_lines.append(temp)
		total = end+skip_step
	return dash_lines
	
