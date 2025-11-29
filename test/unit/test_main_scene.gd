extends GutTest

var main_scene: PackedScene
var main_node: Node2D

class FakeCard:
	extends Control
	func getCardHint() -> String:
		return "Fake Hint"
	func getCardUseHeader() -> String:
		return "Fake Header"
	func use() -> void:
		pass

class FakeCardHintNode:
	extends Node
	var hint_text: String = ""
	func getCardHint() -> String:
		return hint_text

func before_all():
	main_scene = load("res://Model/Scenes/MainScene.tscn")

func before_each():
	main_node = main_scene.instantiate()
	get_tree().root.add_child(main_node)  # attach to running scene tree
	get_tree().current_scene = main_node  # ensures get_tree() works in TitleScreen.gd

func after_each():
	main_node.queue_free()

func test_card_container():
	var card_container =  main_node.get_node_or_null("UI/Hand Container/Card Container")
	assert_not_null(card_container, "CardContainer should exist inside the UI")

func test_left_arrow():
	var Left_Arrow = main_node.get_node_or_null("UI/Hand Container/Left Arrow/Left Arrow Button")
	assert_not_null(Left_Arrow, "Left Arrow button should exist inside the UI")

func test_right_arrow():
	var Right_Arrow = main_node.get_node_or_null("UI/Hand Container/Right Arrow/Right Arrow Button")
	assert_not_null(Right_Arrow, "Right Arrow button should exist inside the UI")

func test_reward_holder():
	var Reward_Holder = main_node.get_node_or_null("UI/Reward Holder")
	assert_not_null(Reward_Holder, "Reward Holder should exist inside the UI")
	
#NOTE: This test is showing as an error even though all asserts that are written pass.
#It says there are 4/5 asserts pass but we only have 4 asserts written in the test
func test_rotate_left():
	var HandScript = load("res://Model/Scenes/HandController.gd")

	var hand = HandScript.new()
	get_tree().root.add_child(hand)

	hand.card_container = Control.new()
	hand.add_child(hand.card_container)
	hand.cardEffectLabel = Label.new()
	hand.add_child(hand.cardEffectLabel)
	hand.continueScenarioControl = Control.new()
	hand.add_child(hand.continueScenarioControl)

	hand.test_mode = true

	for i in range(3):
		var card = FakeCard.new()
		var hint_node = FakeCardHintNode.new()
		hint_node.hint_text = "Hint %d" % i
		card.add_child(hint_node)
		hand.addCard(card)

	hand.selectedIndex = 0
	hand.rotateLeft()
	assert_eq(hand.selectedIndex, 2)
	hand.rotateLeft()
	assert_eq(hand.selectedIndex, 1)
	hand.rotateLeft()
	assert_eq(hand.selectedIndex, 0)

	hand.queue_free()

	var hand2 = HandScript.new()
	get_tree().root.add_child(hand2)

	hand2.card_container = Control.new()
	hand2.add_child(hand2.card_container)
	hand2.cardEffectLabel = Label.new()
	hand2.add_child(hand2.cardEffectLabel)
	hand2.continueScenarioControl = Control.new()
	hand2.add_child(hand2.continueScenarioControl)

	hand2.test_mode = true

	var single_card = FakeCard.new()
	var hint_node2 = FakeCardHintNode.new()
	hint_node2.hint_text = "Single Hint"
	single_card.add_child(hint_node2)
	hand2.addCard(single_card)

	hand2.selectedIndex = 0
	hand2.rotateLeft()
	assert_eq(hand2.selectedIndex, 0)

	hand2.queue_free()

#NOTE: This test is showing as an error even though all asserts that are written pass.
#It says there are 4/5 asserts pass but we only have 4 asserts written in the test
func test_rotate_right():
	var HandScript = load("res://Model/Scenes/HandController.gd")

	var hand = HandScript.new()
	get_tree().root.add_child(hand)

	hand.card_container = Control.new()
	hand.add_child(hand.card_container)
	hand.cardEffectLabel = Label.new()
	hand.add_child(hand.cardEffectLabel)
	hand.continueScenarioControl = Control.new()
	hand.add_child(hand.continueScenarioControl)

	hand.test_mode = true

	for i in range(3):
		var card = FakeCard.new()
		var hint_node = FakeCardHintNode.new()
		hint_node.hint_text = "Hint %d" % i
		card.add_child(hint_node)
		hand.addCard(card)

	hand.selectedIndex = 0
	hand.rotateRight()
	assert_eq(hand.selectedIndex, 1)
	hand.rotateRight()
	assert_eq(hand.selectedIndex, 2)
	hand.rotateRight()
	assert_eq(hand.selectedIndex, 0)

	hand.queue_free()

	var hand2 = HandScript.new()
	get_tree().root.add_child(hand2)

	hand2.card_container = Control.new()
	hand2.add_child(hand2.card_container)
	hand2.cardEffectLabel = Label.new()
	hand2.add_child(hand2.cardEffectLabel)
	hand2.continueScenarioControl = Control.new()
	hand2.add_child(hand2.continueScenarioControl)

	hand2.test_mode = true

	var single_card = FakeCard.new()
	var hint_node2 = FakeCardHintNode.new()
	hint_node2.hint_text = "Single Hint"
	single_card.add_child(hint_node2)
	hand2.addCard(single_card)

	hand2.selectedIndex = 0
	hand2.rotateRight()
	assert_eq(hand2.selectedIndex, 0)

	hand2.queue_free()
