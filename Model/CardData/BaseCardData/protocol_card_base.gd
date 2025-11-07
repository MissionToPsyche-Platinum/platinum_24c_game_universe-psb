extends Node
#Settable card variables
@export var cardName: String
@export var cardSprite: Texture2D 
@export var cardDescription: String
@export var cardBehavior: Array[ICardBehavior]

#references to card nodes
@onready var protocolCardName: Label = $CardBackground/ProtocolCardName
@onready var protocolCardDescription: Label = $CardBackground/ProtocolCardDescription
@onready var protocolCardSprite: Sprite2D = $CardBackground/ProtocolCardSprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	protocolCardName.text = cardName
	protocolCardDescription.text = cardDescription
	protocolCardSprite.texture = cardSprite
	

#signals when the card is clicked
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Card with name " + cardName + " Pressed!")
