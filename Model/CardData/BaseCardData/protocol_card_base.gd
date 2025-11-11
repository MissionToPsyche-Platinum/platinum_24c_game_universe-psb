extends Node

#card signal variable
signal card_used(card) 
#Settable card variables
@export var cardName: String
@export var cardSprite: Texture2D 
@export var cardDescription: String
@export var cardBehavior: Array[Resource]

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
		use();
		
func setupFromResource(resource: Resource) -> void:
	cardName = resource.cardName
	cardSprite = resource.cardSprite
	cardDescription = resource.cardDescription
	cardBehavior = resource.cardBehavior
	
		
func use() -> void:
	for behavior in cardBehavior:
		#type checking like this is necessary in Godot because 
		#declaring a variable of a specific type will only accept that type,
		#not it's subclasses. 
		if behavior is ICardBehavior:
			behavior.use()
		else:
			push_error("Assigned behavior does not implement ICardBehavior!")
	#emit the signal that the card has been used
	emit_signal("card_used", self)
