
extends Node
class_name ProtocolCard

#card signal variable
signal card_used(card) 
signal rewardsClickableHovered(card)
#Settable card variables
@export var cardName: String
@export var cardSprite: Texture2D 
@export var cardDescription: String
@export var cardBehavior: Array[Resource]
@export var cardUseHeader: String
@export var rewardsClickable: Control
@export var cardInfoHolder: Control

#references to card nodes
@export var protocolCardName: Label 
@export var protocolCardDescription: Label 
@export var protocolCardSprite: Sprite2D 

#reference to Extra Info Holder and related nodes
@export var extraInfoHolder: Control
@export var extraInfoButton: Sprite2D
@export var extraInfoHeaderString: String
@export var extraInfoBodyString: String
@export var extraInfoHeader: Label
@export var extraInfoBody: Label

#extra info variables
@export var hasExtraInfo : bool
var showingExtraInfo := false


signal rewardChosen(card)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	protocolCardName.text = cardName
	protocolCardDescription.text = cardDescription
	protocolCardSprite.texture = cardSprite
	
	if hasExtraInfo:
		extraInfoHeader.text = extraInfoHeaderString
		extraInfoBody.text = extraInfoBodyString
		extraInfoButton.visible = true 
		showingExtraInfo = false
		
	
	
		
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
			await behavior.use()
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
		emit_signal("rewardChosen", self)
		
func isCardPlayable() -> bool:
	for behavior in cardBehavior:
		if (!behavior.isCardPlayable()):
			return false
	return true
	
	
func toggleExtraInfo() -> void: 
	if showingExtraInfo:
		#are currently showing extra info, toggle card data
		extraInfoHolder.visible = false
		cardInfoHolder.visible = true
		showingExtraInfo = false
	else:
		#currently not showing extra info, show it
		extraInfoHolder.visible = true
		cardInfoHolder.visible = false
		showingExtraInfo = true
	


func _on_extra_info_button_pressed() -> void:
	toggleExtraInfo()


func _on_reward_clickable_mouse_entered() -> void:
	emit_signal("rewardsClickableHovered", self)
