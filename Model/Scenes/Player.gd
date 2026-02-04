extends Node
class_name Player

var deck: Array[PackedScene] = []
var discards: Array[PackedScene] = []
var hand: Array[PackedScene] = []


#attributes:
@export var HULL_INTEGRITY_MAX = 200
@export var hullIntegrity: float = 100

@export var VELOCITY_MAX = 200
@export var velocity = 100

@export var POWER_MAX = 200
@export var power = 100

@export var BEGINNING_DECK_SIZE = 5

func instantiatePlayerDeck() -> void:
	
	deck = GameManager.card_manager.getDefaultDeck()
	deck.shuffle()

	

func getNewHand() -> void:
	for i in range(BEGINNING_DECK_SIZE):
		drawCard()

func beginPlayerTurn() -> void:
	drawCard()

func drawCard() -> void:
	if deck.is_empty():
		print("Attempted to draw from empty deck!")
		return

	var packed_scene = deck.pop_back()
	#add card to hand
	hand.append(packed_scene)

	
	#show the drawn card to the player
	GameManager.drawCardPreview.drawCardPreview(packed_scene)
	

	#instantiate card to put on the UI
	var card_instance = packed_scene.instantiate()
	
	card_instance.set_meta("source_scene", packed_scene)

	# send card directly to the UI
	GameManager.handController.addCard(card_instance)

	# listen for usage
	card_instance.connect("card_used", Callable(self, "discardCard"))

func discardCard(card_node: Node) -> void:
	var packed_scene = card_node.get_meta("source_scene")
	if packed_scene:
		discards.append(packed_scene)
		hand.erase(packed_scene)

	# tell HandController to remove the card’s wrapper
	GameManager.handController.removeCard(card_node)


func resetDiscards() -> void:
	deck += discards
	deck.shuffle()
	print("Reseting discards, deck should have " + str(deck.size() + discards.size()) + " cards:")
	print(deck)
	discards.clear()

func returnAllCards() -> void:
	resetDiscards()
	for scene in hand:
		deck.append(scene)
	hand.clear()
	deck.shuffle()
	

# Attribute modification remains unchanged:
func setHullIntegrity(amount: float) -> void:
	var add = amount
	if hullIntegrity + amount <= 0:
		GameManager.loseGame()
	if hullIntegrity + amount >= HULL_INTEGRITY_MAX:
		add = HULL_INTEGRITY_MAX - hullIntegrity

	hullIntegrity += add
	GameManager.hullIntegrityLabel.text = "Psyche Hull Integrity: %s" % hullIntegrity
	GameManager.hullIntegrityBar.value = hullIntegrity

func setVelocity(amount: float) -> void:
	var add = amount
	if velocity + amount <= 0:
		GameManager.loseGame()
	if velocity + amount > VELOCITY_MAX:
		add = VELOCITY_MAX - velocity

	velocity += add
	GameManager.veloctiyLabel.text = "Psyche Velocity: %s" % velocity
	GameManager.velocityBar.value = velocity

func setPower(amount: float) -> void:
	var add = amount
	if power + amount <= 0:
		GameManager.loseGame()
	if power + amount > POWER_MAX:
		add = POWER_MAX - power

	power += add
	GameManager.powerLabel.text = "Psyche Power: %s" % power
	GameManager.powerBar.value = power
