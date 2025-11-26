extends Node
class_name Player

@export var cardManager: CardManager

var deck: Array[PackedScene] = []
var discards: Array[PackedScene] = []

#attributes:
@export var HULL_INTEGRITY_MAX = 200
@export var hullIntegrity: float = 100

@export var VELOCITY_MAX = 200
@export var velocity = 100

@export var POWER_MAX = 200
@export var power = 100

@export var BEGINNING_DECK_SIZE = 5

func getNewHand() -> void:
	deck = cardManager.getDefaultDeck()
	deck.shuffle()

	for i in range(BEGINNING_DECK_SIZE):
		drawCard()

func beginPlayerTurn() -> void:
	drawCard()

func drawCard() -> void:
	if deck.is_empty():
		print("Attempted to draw from empty deck!")
		return

	var packed_scene = deck.pop_back()
	var card_instance = packed_scene.instantiate()

	card_instance.set_meta("source_scene", packed_scene)

	# send card directly to the UI
	GameManager.handController.addCard(card_instance)

	# listen for usage
	card_instance.connect("card_used", Callable(self, "_on_card_used"))

func _on_card_used(card_node: Node) -> void:
	var packed_scene = card_node.get_meta("source_scene")
	if packed_scene:
		discards.append(packed_scene)

	# tell HandController to remove the card’s wrapper
	GameManager.handController.removeCard(card_node)

	GameManager.endPlayerTurn()


func resetDiscards() -> void:
	deck += discards
	deck.shuffle()
	discards.clear()


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
