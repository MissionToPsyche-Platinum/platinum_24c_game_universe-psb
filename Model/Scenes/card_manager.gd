extends Node
class_name CardManager

#the basic deck that the player starts with 
@export var defaultDeck: Array[PackedScene] = []
#the cards the player can earn as rewards
@export var bank: Array[PackedScene] = []

#random number generator
var rng = RandomNumberGenerator.new()

#determines the minimum and maximum amount of cards that 
@export var rewardMinimumAmount = 2
@export var rewardMaximumAmount = 3


func _ready() -> void:
	# Copy the templates into the deck and shuffle
	defaultDeck.shuffle()
	bank.shuffle()
	print("Deck initialized with %d cards." % defaultDeck.size())
	


func onCardUsed(card: Node) -> void:
	print("Card Manager: Card %s was used!", card.cardName)
	var wrapper := card.get_parent()
	if wrapper:
		wrapper.remove_child(card)
		wrapper.queue_free()
	
func getDefaultDeck() -> Array[PackedScene]:
	return defaultDeck
	

func getReward() -> Array[PackedScene]:
	#randomize how many reward cards the player will recieve 
	var rewardAmount = rng.randi_range(rewardMinimumAmount, rewardMaximumAmount)
	#array for holding the chosen reward cards
	var rewards: Array[PackedScene] = []
	
	#check if that many cards are still in the bank
	if rewardAmount <= bank.size():
		#return that many cards
		for i in range(rewardAmount):
			rewards.append(bank.pop_back())
		return rewards
	else:
		#if not, just give them all of the cards in the bank as options
		for i in range(bank.size() - 1 ):
			rewards.append(bank.pop_back())
		return rewards			
	
