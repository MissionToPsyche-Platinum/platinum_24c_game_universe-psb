extends Node
class_name CardManager

@export var cards: Array[PackedScene]

	
var defaultDeck: Array[PackedScene] = []
var hand: Array[Node] = []


func _ready() -> void:
	# Copy the templates into the deck and shuffle
	defaultDeck = cards.duplicate()
	defaultDeck.shuffle()
	print("Deck initialized with %d cards." % defaultDeck.size())
	


func onCardUsed(card: Node) -> void:
	print("Card Manager: Card %s was used!", card.cardName)
	var wrapper := card.get_parent()
	if wrapper:
		wrapper.remove_child(card)
		wrapper.queue_free()
	
func getDefaultDeck() -> Array[PackedScene]:
	return defaultDeck
