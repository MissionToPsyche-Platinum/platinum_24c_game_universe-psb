extends GutTest

const HandController = preload("res://Model/Scenes/HandController.gd")

var hand_controller: HandController

class TestCard:
	extends Control

	var hint := ""
	var use_header := ""
	var used := false

	func getCardHint() -> String:
		return hint

	func getCardUseHeader() -> String:
		return use_header

	func use() -> void:
		used = true

func before_each():
	hand_controller = HandController.new()
	hand_controller.test_mode = true


	hand_controller.card_container = Control.new()

	hand_controller.cardEffectLabel = Label.new()

func make_test_card(name: String = "TestCard") -> TestCard:
	var card = TestCard.new()
	card.name = name
	card.hint = "hint_for_%s" % name
	card.use_header = "use_header_for_%s" % name
	return card

func test_add_card():
	var card = make_test_card("SingleCard")

	# Initially no cards
	assert_eq(hand_controller.cards.size(), 0)

	# Add the card
	hand_controller.addCard(card)

	# Check card count
	assert_eq(hand_controller.cards.size(), 1)

	# Check wrapper contains the card
	var wrapper = hand_controller.cards[0]
	assert_eq(wrapper.get_child(0), card)

	# Check selectedIndex
	assert_eq(hand_controller.selectedIndex, 0)

func test_remove_card():
	var card = make_test_card("SingleCard")
	# Initially no cards
	assert_eq(hand_controller.cards.size(), 0)

	# Add the card
	hand_controller.addCard(card)

	# Check card count
	assert_eq(hand_controller.cards.size(), 1)
	
	hand_controller.removeCard(card)
	
	assert_eq(hand_controller.cards.size(), 0)
