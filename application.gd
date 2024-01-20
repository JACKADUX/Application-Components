extends Control

@onready var dragable_card_component = $MarginContainer/DragableCardComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	_debug()
	
func _debug():
	const BASE_DRAGABLE_CARD = preload("res://components/dragable_card_component/card/base_dragable_card.tscn")
	for i in 5:
		var card := BASE_DRAGABLE_CARD.instantiate()
		dragable_card_component.add_card(card)
		card.label.text = "Boghma-"+str(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
