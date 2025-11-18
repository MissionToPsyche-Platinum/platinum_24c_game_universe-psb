extends Node
class_name Player

#reference to the CardManager
@export var cardManager: CardManager
@export var handBox: NodePath

var deck: Array[PackedScene] = []
var hand: Array[Node] = []
var discards: Array[PackedScene] = []

#attributes:
@export var HULL_INTEGRITY_MAX = 200
@export var hullIntegrity: float = 100

@export var VELOCITY_MAX = 200
@export var velocity = 100

@export var POWER_MAX = 200
@export var power = 100

@export var BEGINNING_DECK_SIZE = 5

func _ready() -> void:
	#get default deck
	deck = cardManager.getDefaultDeck()
	#shuffle deck (May already be shuffled?) and draw cards based on beginning deck size
	deck.shuffle()
	for x in range(BEGINNING_DECK_SIZE):
		drawCard()
	

func beginPlayerTurn() -> void:
	drawCard()


func drawCard() -> void:
	if deck.is_empty():
		print("Attempting to draw cards from empty deck!")
		return
	
	#instantiate card
	var packed_scene = deck.pop_back()
	var drawnCardInstance = packed_scene.instantiate()
	
	drawnCardInstance.set_meta("source_scene", packed_scene)
	
	#add card to scene tree
	var parentNode = get_node(handBox) if handBox != NodePath("") else self
	#wrap the node 2d in a Control node so HBOX renders it properly
	var cardWrapper = Control.new()
	cardWrapper.set_custom_minimum_size(Vector2(100,100))
	parentNode.add_child(cardWrapper)
	cardWrapper.add_child(drawnCardInstance)
	hand.append(drawnCardInstance)
	
	#listen for the card used signal
	drawnCardInstance.connect("card_used", Callable(self, "onCardUsed"))

func onCardUsed(card: Node) -> void:
	#add card to discard pile from the source scene
	#extract the packedScene
	var packedScene = card.get_meta("source_scene")
	if packedScene == null:
		print("ERROR: No source scene metadata on card")
		return
	else:
		discards.append(packedScene)
	
	#remove the card from the H box
	var wrapper := card.get_parent()
	if wrapper:
		wrapper.remove_child(card)
		wrapper.queue_free()
		
	#end the player turn
	print("Player turn over")
	GameManager.endPlayerTurn()
	
func resetDiscards() -> void:
	#add the discards back to the deck
	print("adding cards back into deck")
	deck += discards
	deck.shuffle()
	print(deck)
	#clear the discard pile
	discards.clear()


func _on_empty_discard_pile_button_pressed() -> void:
	resetDiscards()
	
func setHullIntegrity(amount: float) -> void:
	#check for complete loss of attribute
	if hullIntegrity + amount <= 0:
		#call the lose game function
		GameManager.loseGame()
	#check if value goes over max
	if hullIntegrity + amount >= HULL_INTEGRITY_MAX:
		hullIntegrity = HULL_INTEGRITY_MAX
		return
	
	hullIntegrity += amount
	
func setVelocity(amount: float) -> void:
	#check for complete loss of attribute
	if velocity + amount <= 0:
		#call the lose game function
		GameManager.loseGame()
	#check if value goes over max
	if velocity + amount >  VELOCITY_MAX:
		velocity = VELOCITY_MAX
		return
	
	velocity += amount

func setPower(amount: float) -> void:
	#check for complete loss of attribute
	if power + amount <= 0:
		#call the lose game function
		GameManager.loseGame()
	#check if value goes over max
	if power + amount >  POWER_MAX:
		power = POWER_MAX
		return
	
	power += amount
	
	
	
