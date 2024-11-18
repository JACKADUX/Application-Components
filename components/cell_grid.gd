class_name CellGrid extends ScrollContainer

const GAP = 2
const SIDE_BAR_WIDTH :int = 32
const TOP_BAR_HEIGHT :int = 32
const MIN_LENGTH :int = 100

var rs = RenderingServer
var base_rid := rs.canvas_item_create()
var items_rid := rs.canvas_item_create()
var indicator_rid := rs.canvas_item_create()

var SBOX_BG := get_base_stylebox(0)
var SBOX_HOVERED := get_base_stylebox(1)
var SBOX_SELECT := get_base_stylebox(2)
var SBOX_RESIZE_BAR := get_base_stylebox(3)
var SBOX_HOVERED_INDEX := get_base_stylebox(4)

var FONT := get_base_font()

const INTER_VARIABLE_FONT_SLNT_WGHT = preload("res://resource/fonts/inter/Inter-VariableFont_slnt,wght.ttf")

var cells_offset :Vector2:
	get: return Vector2(SIDE_BAR_WIDTH+GAP, TOP_BAR_HEIGHT+GAP)

var cell_x_count :int = 20
var cell_y_count :int = 100
#var bar_rects := {}
var top_bar_rects := {}
var side_bar_rects := {}

var hovered_location := []
var select_locations := []

enum DrawDirty {
	ALL,
	BASE,
	ITEMS,
	INDICATOR,
}
var _dirty_base := false
var _dirty_items := false
var _dirty_indicator := false

enum Actions {
	NORMAL,
	RESIZE_READY,
	RESIZE,
}
var action := Actions.NORMAL
var _resize_bar_location := []
var _start_position := Vector2.ZERO

var cell_items := {}

var parent_rect:=Rect2()



var control :Control

#---------------------------------------------------------------------------------------------------
func _ready():
	control = Control.new()
	add_child(control)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	mouse_exited.connect(func():
		hovered_location = []
		queue_draw(DrawDirty.INDICATOR)
	)
	get_h_scroll_bar().value_changed.connect(func(v):
		queue_draw()
	)
	get_v_scroll_bar().value_changed.connect(func(v):
		queue_draw()
	)
	resized.connect(func():
		queue_draw()
	)
	
	rs.canvas_item_set_parent(base_rid, control.get_canvas_item())
	rs.canvas_item_set_parent(items_rid, control.get_canvas_item())
	rs.canvas_item_set_parent(indicator_rid, control.get_canvas_item())
	
	generate_bars()
	queue_draw()
	
	#
	var DEBUG_TEXTURE = preload("res://resource/place_holder/comp/1000.png")
	for x in cell_x_count:
		for y in cell_y_count:
			if randf() > 0.5:
				set_lable([x, y], "dfas123543dfasdfadfasgcxdfasdfa111121dfasdfasdfadfasdfa78378sdfa")
			else:
				set_texture([x, y], DEBUG_TEXTURE)
				

#---------------------------------------------------------------------------------------------------
func set_texture(location:Array, value:Texture2D):
	cell_items[location] = value
	
#---------------------------------------------------------------------------------------------------
func set_lable(location:Array, value:String):
	cell_items[location] = value

#---------------------------------------------------------------------------------------------------
func _exit_tree():
	rs.free_rid(base_rid)
	rs.free_rid(items_rid)
	rs.free_rid(indicator_rid)

#---------------------------------------------------------------------------------------------------
func queue_draw(draw_dirty:=DrawDirty.ALL):
	match draw_dirty:
		DrawDirty.ALL:
			_dirty_base = true
			_dirty_items = true
			_dirty_indicator = true
		DrawDirty.BASE:
			_dirty_base = true
		DrawDirty.ITEMS:
			_dirty_items = true
		DrawDirty.INDICATOR:
			_dirty_indicator = true

#---------------------------------------------------------------------------------------------------
func _process(delta):
	parent_rect = Rect2(-control.position, size)
	if _dirty_base:
		_dirty_base = false
		draw_cell_grid()
	if _dirty_items:
		_dirty_items = false
		draw_items()
	if _dirty_indicator:
		_dirty_indicator = false
		draw_indicator()



#---------------------------------------------------------------------------------------------------
func _gui_input(event):
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_NONE:
		action = Actions.NORMAL
		var hovered = get_hovered()
		_resize_bar_location = get_resize_bar_location(hovered)
		if hovered == hovered_location:
			return 
		hovered_location = hovered
		queue_draw(DrawDirty.INDICATOR)
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		_start_position = control.get_local_mouse_position()
		match action:
			Actions.NORMAL:
				check_select()
				queue_draw(DrawDirty.INDICATOR)
			Actions.RESIZE_READY:
				action = Actions.RESIZE
				
		
	elif event is InputEventMouseMotion and event.button_mask != MOUSE_BUTTON_NONE:
		if action == Actions.RESIZE: 
			var delta = event.relative as Vector2
			if delta.is_zero_approx():
				return 
			for location:Array in _resize_bar_location:
				var x = location[0]
				var y = location[1]
				var rect:Rect2
				if x == -1: # SIDE
					rect = side_bar_rects[location]
					set_side_bar_size(y, rect.size.y + delta.y)
				elif y == -1: # TOP
					rect = top_bar_rects[location]
					set_top_bar_size(x, rect.size.x + delta.x)
			queue_draw(DrawDirty.ALL)
			
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if action == Actions.RESIZE:
			#queue_draw(DrawDirty.ALL)
			pass


#---------------------------------------------------------------------------------------------------
func get_resize_bar_location(location:Array):
	mouse_default_cursor_shape = CURSOR_ARROW
	var mp := control.get_local_mouse_position()
	var gap = 20 # 拖拽距离
	if not location:
		return []
		
	var resize_bar_location = []
	var rect:Rect2 = get_cell_rect(location)
	var dis = (rect.end - mp).abs()
	
	if location[0] == -1: # side
		if dis.y <= gap:
			mouse_default_cursor_shape = CURSOR_VSIZE
			action = Actions.RESIZE_READY
			resize_bar_location = [location]
			
	elif location[1] == -1: # top
		if dis.x <= gap:
			mouse_default_cursor_shape = CURSOR_HSIZE
			action = Actions.RESIZE_READY
			resize_bar_location = [location]
		
	else:
		if dis.x <= gap and dis.y <= gap:
			mouse_default_cursor_shape = CURSOR_FDIAGSIZE
			action = Actions.RESIZE_READY
			resize_bar_location = [ [-1, location[1]], [location[0],-1] ]
	return resize_bar_location

#---------------------------------------------------------------------------------------------------
func set_top_bar_size(x_index:int, width:float):
	var location = [x_index, -1]
	var bar_rect = top_bar_rects[location]
	bar_rect.size.x = max(MIN_LENGTH, width)
	top_bar_rects[location] = bar_rect
	# 偏移后续的对象
	for i in range(x_index+1, cell_x_count):
		var offset_rect = top_bar_rects[[i, -1]]
		offset_rect.position.x = bar_rect.end.x+GAP
		top_bar_rects[[i, -1]] = offset_rect
		bar_rect = offset_rect
	control.custom_minimum_size = get_cell_rect([cell_x_count-1, cell_y_count-1]).end + Vector2(8, 8)
	
#---------------------------------------------------------------------------------------------------
func set_side_bar_size(y_index:int, height:float):
	var location = [-1, y_index]
	var bar_rect = side_bar_rects[location]
	bar_rect.size.y = max(MIN_LENGTH, height)
	side_bar_rects[location] = bar_rect
	for i in range(y_index+1, cell_y_count):
		var offset_rect = side_bar_rects[[-1, i]]
		offset_rect.position.y = bar_rect.end.y+GAP
		side_bar_rects[[-1, i]] = offset_rect
		bar_rect = offset_rect
	control.custom_minimum_size = get_cell_rect([cell_x_count-1, cell_y_count-1]).end + Vector2(8, 8)
	
	
#---------------------------------------------------------------------------------------------------
func get_hovered_bar() -> Array:
	# bar
	var mp := control.get_local_mouse_position()
	if mp.y <= TOP_BAR_HEIGHT:
		var x_start = false
		for location: Array in top_bar_rects:
			var rect = top_bar_rects[location]
			# Skip start
			if not x_start:
				if parent_rect.position.x > rect.end.x:
					continue
				x_start = true
			# Skip end
			if parent_rect.end.x < rect.position.x:
				break
			
			if rect.has_point(mp):
				return location
	
	if mp.x <= SIDE_BAR_WIDTH:
		var y_start = false
		for location: Array in side_bar_rects:
			var rect = side_bar_rects[location]
			# Skip start
			if not y_start:
				if parent_rect.position.y > rect.end.y:
					continue
				y_start = true
			
			# Skip end
			if parent_rect.end.y < rect.position.y:
				break
			
			if rect.has_point(mp):
				return location
	return []
		
#---------------------------------------------------------------------------------------------------
func get_hovered() -> Array:
	var hovered = get_hovered_bar()
	if hovered:
		return hovered
	var mp := control.get_local_mouse_position()
	# [x, y]
	var start = false
	for x in range(cell_x_count):
		for y in range(cell_y_count):
			var location = [x, y]
			var rect:Rect2 = get_cell_rect(location)
			## Skip start
			if not start:
				if rect.end.x < parent_rect.position.x or rect.end.y < parent_rect.position.y :
					continue
				start = true
			if not parent_rect.intersects(rect):
				## Skip ends
				if parent_rect.end.x < rect.position.x and parent_rect.end.y < rect.end.y :
					return []
				continue
			if rect.has_point(mp):
				return location
	return []

#---------------------------------------------------------------------------------------------------
func generate_bars():
	if cell_x_count <= 0 or cell_y_count <= 0:
		control.custom_minimum_size = Vector2.ZERO
		return
	top_bar_rects = {}
	side_bar_rects = {}
	var top_bar_rect := Rect2(SIDE_BAR_WIDTH, 0, MIN_LENGTH, TOP_BAR_HEIGHT)
	for x in range(cell_x_count):
		top_bar_rect.position = Vector2(SIDE_BAR_WIDTH + GAP + x*(MIN_LENGTH + GAP), 0)
		top_bar_rects[[x, -1]] = top_bar_rect
	
	var side_bar_rect := Rect2(0, TOP_BAR_HEIGHT, SIDE_BAR_WIDTH, MIN_LENGTH)
	for y in range(cell_y_count):
		side_bar_rect.position = Vector2(0, TOP_BAR_HEIGHT + GAP + y*(MIN_LENGTH + GAP))
		side_bar_rects[[-1, y]] = side_bar_rect
	
	control.custom_minimum_size = get_cell_rect([cell_x_count-1, cell_y_count-1]).end + Vector2(8, 8)
	
#---------------------------------------------------------------------------------------------------
func get_cell_rect(location:Array) -> Rect2:
	# 也会返回 bar rect
	var x = location[0]
	var y = location[1]
	if x == -1:
		return side_bar_rects[location]
	if y == -1:
		return top_bar_rects[location]	
	var bar_x_rect = top_bar_rects[[x, -1]]
	var bar_y_rect = side_bar_rects[[-1, y]]
	return Rect2(bar_x_rect.position.x, bar_y_rect.position.y, bar_x_rect.size.x, bar_y_rect.size.y)

#---------------------------------------------------------------------------------------------------
func check_select():
	var shift_pressed := Input.is_key_pressed(KEY_SHIFT)
	var ctrl_pressed := Input.is_key_pressed(KEY_CTRL)
	if not shift_pressed and not ctrl_pressed:
		select_locations = []
	if not hovered_location:
		return
	
	# 整行整列选择
	if hovered_location[0] == -1: # SIDE
		if ctrl_pressed:
			for x in range(cell_x_count):
				set_select([x, hovered_location[1]], false)
		else:
			for x in range(cell_x_count):
				set_select([x, hovered_location[1]], true)
		return 
	elif hovered_location[1] == -1: # TOP
		if ctrl_pressed:
			for y in range(cell_y_count):
				set_select([hovered_location[0], y], false)
		else:
			for y in range(cell_y_count):
				set_select([hovered_location[0], y], true)
		return
		
	# 连选
	if ctrl_pressed:
		set_select(hovered_location, false)
	elif shift_pressed:
		if select_locations:
			var start_x = select_locations[-1][0]
			var start_y = select_locations[-1][1]
			if start_x == hovered_location[0]:
				var ran = abs(start_y - hovered_location[1])
				var sig = sign(hovered_location[1]-start_y)
				for y in ran:
					var new_index = y*sig+start_y+sig
					set_select([start_x, new_index], true)
					
			elif start_y == hovered_location[1]:
				var ran = abs(start_x - hovered_location[0])
				var sig = sign(hovered_location[0]-start_x)
				for x in ran:
					var new_index = x*sig+start_x+sig
					set_select([new_index, start_y], true)
		set_select(hovered_location, true)
		
	else:
		set_select(hovered_location, true)
		
#---------------------------------------------------------------------------------------------------
func is_selected(location:Array):
	return location in select_locations

#---------------------------------------------------------------------------------------------------
func set_select(location:Array, value:bool):
	if not value:
		select_locations.erase(location)
	elif value and select_locations.find(location) == -1:
		select_locations.append(location)

#---------------------------------------------------------------------------------------------------
# [ THEME ]
#---------------------------------------------------------------------------------------------------
func get_base_stylebox(type:int=0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	match type:
		0:
			box.bg_color = Color.BLACK
		1:
			box.draw_center = false
			box.border_color = Color.WEB_GRAY
			box.set_border_width_all(1)
		2:
			box.draw_center = false
			box.border_color = Color.GREEN
			box.set_border_width_all(1)
		3: # bar resize
			box.draw_center = false
			box.border_color = Color.WHITE
			box.set_border_width_all(1)
		4: # SBOX_HOVERED_INDEX
			box.bg_color = Color.WHITE_SMOKE
			box.corner_radius_top_left = 4
			box.corner_radius_top_right = 4
			
			
	return box

func get_base_font() -> FontVariation:
	var font := FontVariation.new()
	font.set_base_font(INTER_VARIABLE_FONT_SLNT_WGHT)
	return font
	

#---------------------------------------------------------------------------------------------------
# [ CANVAS ]
#---------------------------------------------------------------------------------------------------
func draw_cell_grid():
	#print("drawing")
	rs.canvas_item_clear(base_rid)
	if cell_x_count <= 0 or cell_y_count <= 0:
		return
	draw_bar()
	draw_cells()

#---------------------------------------------------------------------------------------------------
func draw_bar():
	#SBOX_BG.draw(base_rid, Rect2(0,0,SIDE_BAR_WIDTH, TOP_BAR_HEIGHT))
	rs.canvas_item_add_rect(base_rid, Rect2(0,0,SIDE_BAR_WIDTH, TOP_BAR_HEIGHT), Color.BLACK)

	var ascent = FONT.get_ascent()
	
	var x_start = false
	for x in range(cell_x_count):
		var rect = top_bar_rects[[x, -1]]
		# Skip start
		if not x_start:
			if parent_rect.position.x > rect.end.x:
				continue
			x_start = true
		# Skip end
		if parent_rect.end.x < rect.position.x:
			break
		
		rs.canvas_item_add_rect(base_rid, rect, Color.BLACK)
		#SBOX_BG.draw(base_rid, rect)
		var text = str(x+1)
		var font_size = FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT)
		var offset = (rect.size-font_size)*0.5 + Vector2(0, ascent)
		FONT.draw_string(base_rid, rect.position + offset, text) 
		
	
	var y_start = false
	for y in range(cell_y_count):
		var rect = side_bar_rects[[-1, y]]
		
		# Skip start
		if not y_start:
			if parent_rect.position.y > rect.end.y:
				continue
			y_start = true
		# Skip end
		if parent_rect.end.y < rect.position.y:
			break
		#SBOX_BG.draw(base_rid, rect)
		rs.canvas_item_add_rect(base_rid, rect, Color.BLACK)
		var text = str(y+1)
		var font_size = FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT)
		var offset = (rect.size-font_size)*0.5 + Vector2(0, ascent)
		FONT.draw_string(base_rid, rect.position + offset, text)

#---------------------------------------------------------------------------------------------------
func draw_cells():
	var start = false
	for x in range(cell_x_count):
		for y in range(cell_y_count):
			var location = [x, y]
			var rect:Rect2 = get_cell_rect(location)
			
			## Skip start
			if not start:
				if rect.end.x < parent_rect.position.x or rect.end.y < parent_rect.position.y :
					continue
				start = true
			if not parent_rect.intersects(rect):
				## Skip ends
				if parent_rect.end.x < rect.position.x and parent_rect.end.y < rect.end.y :
					return
				continue

			#SBOX_BG.draw(base_rid, rect)
			rs.canvas_item_add_rect(base_rid, rect, Color("060606"))
		
#---------------------------------------------------------------------------------------------------
func draw_items():
	rs.canvas_item_clear(items_rid)
	var gap = 8
	var font_size = 16
	var ascent = FONT.get_ascent(font_size)
	var text_offset = Vector2(gap, ascent+gap)
	
	var start = false
	for location:Array in cell_items:
		var item = cell_items[location]
		var rect = get_cell_rect(location)
		
		## Skip start
		if not start:
			if rect.end.x < parent_rect.position.x or rect.end.y < parent_rect.position.y :
				continue
			start = true
		if not parent_rect.intersects(rect):
			## Skip ends
			if parent_rect.end.x < rect.position.x and parent_rect.end.y < rect.end.y :
				break
			continue
		if item is Texture2D:
			var texture_aspect = item.get_size().aspect()
			var rect_aspect = rect.size.aspect()
			var old_size = rect.size
			if texture_aspect < rect_aspect:
				rect.size.x = rect.size.y*texture_aspect
				rect.position.x += (old_size-rect.size).x*0.5
			else:
				rect.size.y = rect.size.x/texture_aspect
				rect.position.y += (old_size-rect.size).y*0.5
			rs.canvas_item_add_texture_rect(items_rid, rect, item.get_rid())
			
		elif item is String:
			var max_lines = int((rect.size.y-gap*2) / FONT.get_height(font_size))
			var width = rect.size.x-gap*2
			FONT.draw_multiline_string(items_rid, rect.position + text_offset, item, 0, width, font_size, max_lines, Color.WHITE_SMOKE, TextServer.BREAK_GRAPHEME_BOUND)
	
#---------------------------------------------------------------------------------------------------
func draw_indicator():
	rs.canvas_item_clear(indicator_rid)
	if hovered_location:
		var rect:Rect2 = get_cell_rect(hovered_location)
		SBOX_HOVERED.draw(indicator_rid, rect)
		if hovered_location[0] != -1 and hovered_location[1] != -1:
			var font_size = 16
			var text= str(hovered_location[0]+1)+" , " + str(hovered_location[1]+1)
			var ascent = FONT.get_ascent(font_size)
			var text_size = FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, font_size)
			var text_rect := Rect2(rect.position.x, rect.position.y-text_size.y, text_size.x+8, text_size.y)
			var offset = (text_rect.size-text_size)*0.5 + Vector2(0, ascent)
			SBOX_HOVERED_INDEX.draw(indicator_rid, text_rect)
			FONT.draw_string(indicator_rid, text_rect.position + offset, text, 0, rect.size.x,font_size,Color.BLACK)
		
	if select_locations:
		for location:Array in select_locations:
			var rect:Rect2 = get_cell_rect(location)
			SBOX_SELECT.draw(indicator_rid, rect)
	






















