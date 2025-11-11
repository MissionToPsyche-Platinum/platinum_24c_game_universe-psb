extends Node
class_name cardManager

@export var cards: Array[PackedScene]
@export var handBox: NodePath
	
var deck: Array[PackedScene] = []
var hand: Array[Node] = []


func _ready() -> void:
	# Copy the templates into the deck and shuffle
	deck = cards.duplicate()
	deck.shuffle()
	print("Deck initialized with %d cards." % deck.size())
	
func drawCard() -> void:
	if deck.is_empty():
		print("Attempting to draw cards from empty deck!")
		return
	
	#instantiate the card
	var drawnCardInstance = deck.pop_back().instantiate()
	
	#add card to scene tree
	var parentNode = get_node(handBox) if handBox != NodePath("") else self
	#wrap the node 2d in a Control node so HBOX renders it properly
	var cardWrapper = Control.new()
	cardWrapper.set_custom_minimum_size(Vector2(300,300))
	parentNode.add_child(cardWrapper)
	cardWrapper.add_child(drawnCardInstance)
	hand.append(drawnCardInstance)
	
	#listen for the card used signal
	drawnCardInstance.connect("card_used", Callable(self, "onCardUsed"))

func onCardUsed(card: Node) -> void:
	print("Card Manager: Card %s was used!", card.cardName)
	var wrapper := card.get_parent()
	if wrapper:
		wrapper.remove_child(card)
		wrapper.queue_free()
	


func _on_button_pressed() -> void:
	drawCard()
