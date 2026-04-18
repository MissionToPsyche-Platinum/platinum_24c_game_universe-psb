extends GutTest

# Preloads
const HandController = preload("res://Model/Scenes/HandController.gd")
const Player = preload("res://Model/Scenes/Player.gd")

var hand_controller: HandController

# -----------------------------
# Fake Player for testing
# -----------------------------
class FakePlayer:
	extends Player

	var discarded: Array = []
	var draw_calls := 0

	func discardCard(card) -> void:
		discarded.append(card)

	func drawCard(_animate: bool) -> void:
		draw_calls += 1

# -----------------------------
# Test Card
# -----------------------------
class TestCard:
	extends Control
	var id: String

	func _init(_id: String = ""):
		id = _id

# -----------------------------
# Setup / Teardown
# -----------------------------
func before_each():
	# Create hand controller
	hand_controller = HandController.new()
	hand_controller.test_mode = true
	add_child_autofree(hand_controller)

	# Card container (UI) and continue control
	hand_controller.card_container = Control.new()
	hand_controller.continueScenarioControl = Control.new()
	hand_controller.continueScenarioControl.visible = false

	# Animation players
	hand_controller.trashcanAnimationPlayer = AnimationPlayer.new()
	var trash_lib := AnimationLibrary.new()
	trash_lib.add_animation("Open", Animation.new())
	trash_lib.add_animation("Close", Animation.new())
	hand_controller.trashcanAnimationPlayer.add_animation_library("test", trash_lib)

	hand_controller.discardCardButtonAnimationPlayer = AnimationPlayer.new()
	var discard_lib := AnimationLibrary.new()
	discard_lib.add_animation("Startup", Animation.new())
	discard_lib.add_animation("Hide", Animation.new())
	hand_controller.discardCardButtonAnimationPlayer.add_animation_library("test", discard_lib)

	# Label for effects
	hand_controller.cardEffectLabel = Label.new()

	# Inject fake player
	GameManager.player = FakePlayer.new()
	GameManager.handController = hand_controller

func after_each():
	# Free all cards in hand controller
	for c in hand_controller.cards:
		if c.is_inside_tree():
			c.queue_free()
	hand_controller.cards.clear()
	hand_controller.holdingDiscards.clear()

	# Free animation players
	if hand_controller.trashcanAnimationPlayer:
		hand_controller.trashcanAnimationPlayer.queue_free()
	if hand_controller.discardCardButtonAnimationPlayer:
		hand_controller.discardCardButtonAnimationPlayer.queue_free()

	# Free controls
	if hand_controller.card_container:
		hand_controller.card_container.queue_free()
	if hand_controller.continueScenarioControl:
		hand_controller.continueScenarioControl.queue_free()

	# Free hand controller itself
	if hand_controller.is_inside_tree():
		hand_controller.queue_free()
	hand_controller = null

	# Reset GameManager
	GameManager.player = null
	GameManager.handController = null

# -----------------------------
# Helpers
# -----------------------------
func make_cards(n: int) -> Array[TestCard]:
	var created: Array[TestCard] = []
	for i in range(n):
		var c := TestCard.new("C%s" % i)
		hand_controller.addCard(c)
		created.append(c)
	return created

# -----------------------------
# Tests
# -----------------------------
func test_SF_M_01_toggle_adds_and_removes_selected_card():
	var cards := make_cards(3)
	hand_controller.selectedIndex = 1

	hand_controller._on_toggle_discard_button_pressed()
	assert_true(hand_controller.holdingDiscards.has(cards[1]))

	hand_controller._on_toggle_discard_button_pressed()
	assert_false(hand_controller.holdingDiscards.has(cards[1]))


func test_SF_M_04_discard_entire_hand_draws_replacements():
	var cards := make_cards(3)
	var player: FakePlayer = GameManager.player

	for c in cards:
		hand_controller.holdingDiscards[c] = true

	hand_controller._on_discard_button_pressed()

	assert_eq(player.discarded.size(), 3)
	assert_eq(player.draw_calls, 3)
	assert_eq(hand_controller.holdingDiscards.size(), 0)


func test_SF_M_03_discard_draws_same_amount_as_discarded():
	var cards := make_cards(4)
	var player: FakePlayer = GameManager.player

	hand_controller.holdingDiscards[cards[0]] = true
	hand_controller.holdingDiscards[cards[3]] = true

	hand_controller._on_discard_button_pressed()

	assert_eq(player.discarded.size(), 2)
	assert_true(player.discarded.has(cards[0]))
	assert_true(player.discarded.has(cards[3]))
	assert_eq(player.draw_calls, 2)
	assert_eq(hand_controller.holdingDiscards.size(), 0)


func test_SF_M_04_can_discard_hand_size_minus_one():
	var cards := make_cards(4)
	var player: FakePlayer = GameManager.player

	hand_controller.holdingDiscards[cards[0]] = true
	hand_controller.holdingDiscards[cards[1]] = true
	hand_controller.holdingDiscards[cards[2]] = true

	hand_controller._on_discard_button_pressed()

	assert_eq(player.discarded.size(), 3)
	assert_eq(player.draw_calls, 3)
	assert_eq(hand_controller.holdingDiscards.size(), 0)


func test_SF_M_02_discarded_card_removed_from_hand_and_ui():
	# Use real Player
	var real_player := Player.new()
	add_child_autofree(real_player)
	GameManager.player = real_player
	GameManager.handController = hand_controller

	var card := TestCard.new("DiscardMe")
	hand_controller.addCard(card)

	var packed := PackedScene.new()
	card.set_meta("source_scene", packed)
	real_player.hand.append(packed)

	# Discard card
	real_player.discardCard(card)

	assert_false(real_player.hand.has(packed))
	assert_true(real_player.discards.has(packed))
	assert_false(hand_controller.cards.has(card))
