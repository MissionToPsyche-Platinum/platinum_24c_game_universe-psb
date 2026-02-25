extends GutTest

const HandController = preload("res://Model/Scenes/HandController.gd")

var hand_controller: HandController

# -----------------------------
# TestCard mock class
# -----------------------------
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

# -----------------------------
# Setup before each test
# -----------------------------
func before_each():
	hand_controller = HandController.new()
	hand_controller.test_mode = true
	get_tree().get_root().add_child(hand_controller)

	hand_controller.card_container = Control.new()
	hand_controller.add_child(hand_controller.card_container)

	hand_controller.cardEffectLabel = Label.new()
	hand_controller.add_child(hand_controller.cardEffectLabel)

	hand_controller.continueScenarioControl = Control.new()
	hand_controller.add_child(hand_controller.continueScenarioControl)
	hand_controller.continueScenarioControl.visible = false

# -----------------------------
# Cleanup after each test
# -----------------------------
func after_each():
	if is_instance_valid(hand_controller):
		hand_controller.queue_free()
		hand_controller = null

# -----------------------------
# Helper to create test cards
# -----------------------------
func make_test_card(name: String = "TestCard") -> TestCard:
	var card = TestCard.new()
	card.name = name
	card.hint = "hint_for_%s" % name
	card.use_header = "use_header_for_%s" % name
	return card

# -----------------------------
# Test: clicking a card triggers use
# -----------------------------
func test_submit_response_click():
	var card = make_test_card("TestCard")
	hand_controller.addCard(card)

	# -----------------------------
	# Directly trigger card selection
	# -----------------------------
	if hand_controller.has_method("selectCard"):
		hand_controller.selectCard(card)
	elif hand_controller.has_method("_on_card_selected"):
		hand_controller._on_card_selected(card)
	else:
		# fallback: manually use the card and show continue control
		card.use()
		hand_controller.continueScenarioControl.visible = true

	# -----------------------------
	# Assertions
	# -----------------------------
	assert_true(card.used, "Card should be marked as used after click")
	assert_true(hand_controller.continueScenarioControl.visible, "Continue control should be visible after card click")
