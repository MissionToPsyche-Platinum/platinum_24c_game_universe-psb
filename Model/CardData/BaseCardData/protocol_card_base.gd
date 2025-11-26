
extends Node
class_name ProtocolCard

#card signal variable
signal card_used(card) 
#Settable card variables
@export var cardName: String
@export var cardSprite: Texture2D 
@export var cardDescription: String
@export var cardBehavior: Array[Resource]
@export var cardUseHeader: String
@export var rewardsClickable: Control

#references to card nodes
@onready var protocolCardName: Label = $CardBackground/ProtocolCardName
@onready var protocolCardDescription: Label = $CardBackground/ProtocolCardDescription
@onready var protocolCardSprite: Sprite2D = $CardBackground/ProtocolCardSprite

signal rewardChosen(card)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	protocolCardName.text = cardName
	protocolCardDescription.text = cardDescription
	protocolCardSprite.texture = cardSprite
	
		
func setupFromResource(resource: Resource) -> void:
	cardName = resource.cardName
	cardSprite = resource.cardSprite
	cardDescription = resource.cardDescription
	cardBehavior = resource.cardBehavior
	
		
func use() -> void:
	#first check if card is playable
	for behavior in cardBehavior:
		if behavior is ICardBehavior:
			if (!behavior.isCardPlayable()):
				print("Card is not playable!")
				return 
		else:
			push_error("Assigned behavior does not implement ICardBehavior!")
			return
			
	#card is playable, play card
	for behavior in cardBehavior:
		#type checking like this is necessary in Godot because 
		#declaring a variable of a specific type will only accept that type,
		#not it's subclasses. 
		if behavior is ICardBehavior:
			behavior.use()
	#emit the signal that the card has been used
	emit_signal("card_used", self)

func getCardHint() -> String:
	var hint = ""
	for behavior in cardBehavior:
		hint += behavior.getBehaviorHint()
		hint += "\n"
		
	return hint

func getCardUseHeader() -> String:
	return cardUseHeader
	
func enableRewardsClickable() -> void:
	rewardsClickable.visible = true
	
func disableRewardsClickable() -> void:
	rewardsClickable.visible = false
	

func _on_reward_clickable_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("help")
		emit_signal("rewardChosen", self)
