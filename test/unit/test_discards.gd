extends GutTest

const HandController = preload("res://Model/Scenes/HandController.gd")
const Player = preload("res://Model/Scenes/Player.gd")

var hand_controller: HandController

class FakePlayer:
	extends Player

	var discarded: Array = []
	var draw_calls := 0

	func discardCard(card) -> void:
		discarded.append(card)

	func drawCard(_animate: bool) -> void:
		draw_calls += 1


class TestCard:
	extends Control
	var id: String

	func _init(_id: String = ""):
		id = _id


func before_each():
	hand_controller = HandController.new()
	hand_controller.test_mode = true

	# Required for addCard()
	hand_controller.card_container = Control.new()

	# Needed because toggle plays animations
	hand_controller.trashcanAnimationPlayer = AnimationPlayer.new()
	hand_controller.discardCardButtonAnimationPlayer = AnimationPlayer.new()

	# Safe stubs
	hand_controller.cardEffectLabel = Label.new()
	hand_controller.continueScenarioControl = Control.new()
	hand_controller.continueScenarioControl.visible = false

	# Inject fake player into autoload
	GameManager.player = FakePlayer.new()
	
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



func make_cards(n: int) -> Array[TestCard]:
	var created: Array[TestCard] = []
	for i in range(n):
		var c := TestCard.new("C%s" % i)
		hand_controller.addCard(c)
		created.append(c)
	return created


func test_SF_M_01_toggle_adds_and_removes_selected_card():
	var cards := make_cards(3)

	hand_controller.selectedIndex = 1
	hand_controller._on_toggle_discard_button_pressed()
	assert_true(hand_controller.holdingDiscards.has(cards[1]))

	hand_controller._on_toggle_discard_button_pressed()
	assert_false(hand_controller.holdingDiscards.has(cards[1]))


func test_SF_M_04_cannot_discard_all_cards_in_hand():
	var cards := make_cards(3)
	var player: FakePlayer = GameManager.player

	for c in cards:
		hand_controller.holdingDiscards[c] = true

	hand_controller._on_discard_button_pressed()

	assert_eq(player.discarded.size(), 0)
	assert_eq(player.draw_calls, 0)
	assert_eq(hand_controller.holdingDiscards.size(), 3) # unchanged because discard blocked


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
	hand_controller.holdingDiscards[cards[2]] = true # 3 discards, 4 in hand

	hand_controller._on_discard_button_pressed()

	assert_eq(player.discarded.size(), 3)
	assert_eq(player.draw_calls, 3)
	assert_eq(hand_controller.holdingDiscards.size(), 0)

func test_SF_M_02_discarded_card_removed_from_hand_and_ui():
	# Use the real Player.discardCard implementation
	var real_player := Player.new()
	add_child_autofree(real_player)
	GameManager.player = real_player

	# HandController must be reachable from GameManager.player.discardCard()
	GameManager.handController = hand_controller

	# Create a card node and add it to the HandController UI
	var card := TestCard.new("DiscardMe")
	hand_controller.addCard(card)

	# Simulate what your real cards do: store the PackedScene they came from
	var packed := PackedScene.new()
	card.set_meta("source_scene", packed)

	# Simulate that this packed scene is currently in the player's hand
	real_player.hand.append(packed)
	# Ensure discards exists/empty (if not already)
	# real_player.discards = []  # only if needed in your Player.gd

	# Discard it
	real_player.discardCard(card)

	# Assertions: removed from player's hand, added to discards
	assert_false(real_player.hand.has(packed))
	assert_true(real_player.discards.has(packed))

	# Assertions: removed from UI list so it cannot be selected/used anymore
	assert_false(hand_controller.cards.has(card))
