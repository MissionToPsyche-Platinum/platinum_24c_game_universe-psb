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
	hand_controller.continueScenarioControl = Control.new()
	hand_controller.continueScenarioControl.visible = false

func make_test_card(name: String = "TestCard") -> TestCard:
	var card = TestCard.new()
	card.name = name
	card.hint = "hint_for_%s" % name
	card.use_header = "use_header_for_%s" % name
	return card

func test_submit_response_click():
	var card = make_test_card("TestCard")
	hand_controller.addCard(card)

	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true

	hand_controller._on_select_response_label_gui_input(event)

	assert_true(card.used)
	assert_true(hand_controller.continueScenarioControl.visible)
