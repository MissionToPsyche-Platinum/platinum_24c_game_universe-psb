extends GutTest

const HandController = preload("res://Model/Scenes/HandController.gd")

var hand_controller: HandController


class TestCard:
	extends Control

	var hint := ""
	var use_header := ""
	var used := false
	var playable := true
	var received_target: Variant = null  # explicit type

	func isCardPlayable() -> bool:
		return playable

	func getCardHint() -> String:
		return hint

	func getCardUseHeader() -> String:
		return use_header

	# ✅ Parameter type declared as Variant
	func use(p_target: Variant = null) -> void:
		received_target = p_target
		used = true

# -----------------------------
# Setup
# -----------------------------
func before_each():
	hand_controller = HandController.new()
	hand_controller.test_mode = true

	# Manually assign required nodes (since _ready is skipped in test_mode)
	hand_controller.card_container = Control.new()
	hand_controller.cardEffectLabel = Label.new()


func make_test_card(name: String = "TestCard") -> TestCard:
	var card = TestCard.new()
	card.name = name
	card.hint = "hint_for_%s" % name
	card.use_header = "use_header_for_%s" % name
	return card


# -----------------------------
# Tests
# -----------------------------
func test_add_card():
	var card = make_test_card("SingleCard")

	assert_eq(hand_controller.cards.size(), 0)

	hand_controller.addCard(card)

	assert_eq(hand_controller.cards.size(), 1)
	assert_eq(hand_controller.cards[0], card)
	assert_eq(hand_controller.selectedIndex, 0)


func test_remove_card():
	var card = make_test_card("SingleCard")

	assert_eq(hand_controller.cards.size(), 0)

	hand_controller.addCard(card)
	assert_eq(hand_controller.cards.size(), 1)

	hand_controller.removeCard(card)

	assert_eq(hand_controller.cards.size(), 0)


func test_select_card_uses_it():
	var card = make_test_card("PlayableCard")

	hand_controller.addCard(card)

	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true

	hand_controller._on_select_response_label_gui_input(event)

	assert_true(card.used)


func test_unplayable_card_does_not_use():
	var card = make_test_card("UnplayableCard")
	card.playable = false

	hand_controller.addCard(card)

	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true

	hand_controller._on_select_response_label_gui_input(event)

	assert_false(card.used)
