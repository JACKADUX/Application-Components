extends Control

enum ElementType {
	Element,
	ElementRect,
	ElementCircle,
	ElementEllipse,
}

var factory := Factory.new()

class Element extends UniformData:
	@export var title:String = ""
	func get_title():
		return title
	func set_title(value:String):
		title = value
		
class ElementRect extends Element:
	@export var rect:Rect2
	func get_rect():
		return rect
	func set_rect(value:Rect2):
		rect = value

class ElementCircle extends Element:
	@export var center:Vector2
	@export var radius:float
	@export var is_ellipse:bool = false
		
	func get_center():
		return center
	func set_center(value:Vector2):
		center = value


func _ready():
	var solution = 3
	match solution:
		0:	
			print("方法0")
			create_0()
		1:
			print("方法1")
			create_1()
		2:
			print("方法2")
			register_2()
			create_2()
		3:
			print("方法3")
			register_3()
			create_3()	
			
		
#region 0:"直接创建
## 非常混沌，有种原始的美感
func create_0():
	var element = Element.new()
	element._type = ElementType.Element
	element._type_string = "Element"
	element.set_title("element")
	
	var rect = ElementRect.new()
	rect._type = ElementType.ElementRect
	rect._type_string = "ElementRect"
	rect.set_title("rect")
	element.add_child(rect)
	
	var rect_child = ElementRect.new()
	rect._type = ElementType.ElementRect
	rect._type_string = "ElementRect"
	rect_child.set_title("rect_child")	
	rect.add_child(rect_child)
	
	var circle = ElementCircle.new()
	circle._type = ElementType.ElementCircle
	circle._type_string = "ElementCircle"
	circle.set_title("circle")
	element.add_child(circle)
	
	var circle2 = ElementCircle.new()
	circle2._type = ElementType.ElementEllipse
	circle2._type_string = "ElementEllipse"
	circle2.set_title("circle_ellipse")
	circle2.is_ellipse = true
	circle.add_child(circle2)
		
	print_element_tree(element)

#endregion

#region 1:"通过创建方法来创建"
## 已经出现工厂模式的雏形，但注册行为只能发生在当前函数内
## 也就是说任何时候需要新增类型都要修改当前的函数
func create_element(type:ElementType, title:String):
	var element:Element
	match type:
		ElementType.Element:
			element = Element.new()
			element._type_string = "Element"
		ElementType.ElementRect:
			element = ElementRect.new()
			element._type_string = "ElementRect"
		ElementType.ElementCircle:
			element = ElementCircle.new() 
			element._type_string = "ElementCircle"
		ElementType.ElementEllipse:
			element = ElementCircle.new() 
			element._type_string = "ElementEllipse"
			element.is_ellipse = true
		_:
			push_error("type not valid")
	element._type = type
	element.set_title(title)
	return element
	
func create_1():
	var element = create_element(ElementType.Element,  "element")
	
	var rect = create_element(ElementType.ElementRect, "rect")
	element.add_child(rect)
	
	var rect_child = create_element(ElementType.ElementRect, "rect_child")
	rect.add_child(rect_child)
	
	var circle = create_element(ElementType.ElementCircle, "circle")
	element.add_child(circle)
	
	var circle2 = create_element(ElementType.ElementEllipse, "circle_ellipse")
	circle.add_child(circle2)
		
	print_element_tree(element)
	
#endregion

#region 2:"最基础工厂方法创建"
## 灵活的注册对象，注册行为可以发生在任何一个能获取到factory对象的位置
func register_2():
	factory.register(ElementType.Element, func():
		var element = Element.new()
		element._type = ElementType.Element
		element._type_string = "Element"
		return element
	)
	factory.register(ElementType.ElementRect, func():
		var element = ElementRect.new()
		element._type = ElementType.ElementRect
		element._type_string = "ElementRect"
		return element
	)
	factory.register(ElementType.ElementCircle, func():
		var element = ElementCircle.new()
		element._type = ElementType.ElementCircle
		element._type_string = "ElementCircle"
		return element
	)
	factory.register(ElementType.ElementEllipse, func():
		var element = ElementCircle.new()
		element._type = ElementType.ElementEllipse
		element._type_string = "ElementEllipse"
		element.is_ellipse = true
		return element
	)

func create_2():
	var element = factory.create(ElementType.Element)
	element.set_title("element")
	
	var rect = factory.create(ElementType.ElementRect)
	rect.set_title("rect")
	element.add_child(rect)
	
	var rect_child = factory.create(ElementType.ElementRect)
	rect_child.set_title("rect_child")
	rect.add_child(rect_child)
	
	var circle = factory.create(ElementType.ElementCircle)
	circle.set_title("circle")
	element.add_child(circle)
	
	var circle2 = factory.create(ElementType.ElementEllipse)
	circle2.set_title("circle_ellipse")
	circle.add_child(circle2)
	
	print_element_tree(element)

#endregion

#region 3:"进阶的工厂方法创建"
## 工厂模式的完美形态，发挥面向对象的真正实力
func simple_register(type:ElementType, object:Object, type_string:String, init_call:Callable=Callable()):
	factory.register(type, func():
		var element = object.new()
		element._type = type
		element._type_string = type_string
		if init_call:
			init_call.call(element)
		return element
	)

func register_3():
	factory.custom_register = simple_register
	simple_register(ElementType.Element, Element, "Element")
	factory.custom_register.call(ElementType.ElementRect, ElementRect, "ElementRect")
	simple_register(ElementType.ElementCircle, ElementCircle, "ElementCircle")
	simple_register(ElementType.ElementEllipse, ElementCircle, "ElementEllipse", func(e): e.is_ellipse = true)

func simple_create(type:ElementType, title:String):
	var element = factory.create(type)
	element.set_title(title)
	return element

func create_3():
	factory.custom_create = simple_create
	var element = simple_create(ElementType.Element, "element")
	
	var rect = simple_create(ElementType.ElementRect, "rect")
	element.add_child(rect)
	
	var rect_child = factory.custom_create.call(ElementType.ElementRect, "rect_child")
	rect.add_child(rect_child)
	
	var circle = simple_create(ElementType.ElementCircle, "circle")
	element.add_child(circle)
	
	var circle2 = simple_create(ElementType.ElementEllipse, "circle_ellipse")
	circle.add_child(circle2)
	
	print_element_tree(element)
#endregion

## Utils
func print_element_tree(element:Element, level:int=0):
	print("\t".repeat(level), element.get_title(), element)
	for child in element.get_children():
		print_element_tree(child, level+1)



































