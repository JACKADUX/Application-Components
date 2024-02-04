extends Control

@onready var draggable_card_component = $DraggableCardComponent

@export var card_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(10):
		var card = card_scene.instantiate()
		draggable_card_component.add_card(card)
		card.set_label("Boghma %d"%i)

