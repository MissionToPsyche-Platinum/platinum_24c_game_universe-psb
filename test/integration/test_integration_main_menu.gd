extends GutTest

# Mock Player for testing
class MockPlayerHull:
	extends Player  # inherit from your Player class

	func _init():
		hullIntegrity = 0  # will trigger loss
		power = 50
		velocity = 50

	# Override methods so they don’t break during tests
	func getNewHand(): pass
	func beginPlayerTurn(): pass
	func returnAllCards(): pass

class MockPlayerPower:
	extends Player  # inherit from your Player class

	func _init():
		hullIntegrity = 50
		power = 0  # will trigger loss
		velocity = 50

	# Override methods so they don’t break during tests
	func getNewHand(): pass
	func beginPlayerTurn(): pass
	func returnAllCards(): pass

class MockPlayerVelocity:
	extends Player  # inherit from your Player class

	func _init():
		hullIntegrity = 50
		power = 50
		velocity = 0  # will trigger loss

	# Override methods so they don’t break during tests
	func getNewHand(): pass
	func beginPlayerTurn(): pass
	func returnAllCards(): pass

# A testable subclass of GameManager for Gut tests
class TestableGameManager:
	extends "res://Controller/GameManager.gd"

	# Override go_to_scene to just record which scene would be loaded
	var scene_changed_path: String = ""

	func change_scene_to_file(path: String) -> void:
		scene_changed_path = path


func test_rotate_left():
	var HandScript = load("res://Model/Scenes/HandController.gd")
	var hand = HandScript.new()
	hand.test_mode = true
	get_tree().root.add_child(hand)

	# Mock necessary nodes
	hand.card_container = Control.new()
	hand.add_child(hand.card_container)
	hand.cardEffectLabel = Label.new()
	hand.add_child(hand.cardEffectLabel)
	hand.continueScenarioControl = Control.new()
	hand.add_child(hand.continueScenarioControl)

	# Fake cards
	for i in range(3):
		var card = Control.new()
		hand.addCard(card)

	hand.selectedIndex = 0
	hand.rotateLeft()
	assert_eq(hand.selectedIndex, 2)
	hand.rotateLeft()
	assert_eq(hand.selectedIndex, 1)
	hand.rotateLeft()
	assert_eq(hand.selectedIndex, 0)

	hand.queue_free()


func test_rotate_right():
	var HandScript = load("res://Model/Scenes/HandController.gd")
	var hand = HandScript.new()
	hand.test_mode = true
	get_tree().root.add_child(hand)

	# Mock necessary nodes
	hand.card_container = Control.new()
	hand.add_child(hand.card_container)
	hand.cardEffectLabel = Label.new()
	hand.add_child(hand.cardEffectLabel)
	hand.continueScenarioControl = Control.new()
	hand.add_child(hand.continueScenarioControl)

	# Fake cards
	for i in range(3):
		var card = Control.new()
		hand.addCard(card)

	hand.selectedIndex = 0
	hand.rotateRight()
	assert_eq(hand.selectedIndex, 1)
	hand.rotateRight()
	assert_eq(hand.selectedIndex, 2)
	hand.rotateRight()
	assert_eq(hand.selectedIndex, 0)

	hand.queue_free()

func test_Hull_Loss():
	var controller = TestableGameManager.new()
	add_child(controller)

	# Mock required nodes
	controller.scenarioHeader = Label.new()
	controller.add_child(controller.scenarioHeader)
	controller.UIAnimationPlayer = AnimationPlayer.new()
	controller.add_child(controller.UIAnimationPlayer)

	# Mock player
	var player = MockPlayerHull.new()
	add_child(player)
	controller.player = player

	# Trigger loss condition
	controller.playerLost = true

	# Call endPlayerTurn
	controller.endPlayerTurn()

	# Assertions
	assert_true(controller.playerLost, "Player should lose when hull hits zero")
	assert_eq(controller.scene_changed_path, "res://Model/ScreenData/LoseScreen.tscn")

	# Cleanup
	player.queue_free()
	controller.queue_free()

func test_Power_Loss():
	var controller = TestableGameManager.new()
	add_child(controller)

	# Mock required nodes
	controller.scenarioHeader = Label.new()
	controller.add_child(controller.scenarioHeader)
	controller.UIAnimationPlayer = AnimationPlayer.new()
	controller.add_child(controller.UIAnimationPlayer)

	# Mock player
	var player = MockPlayerPower.new()
	add_child(player)
	controller.player = player

	# Trigger loss condition
	controller.playerLost = true

	# Call endPlayerTurn
	controller.endPlayerTurn()

	# Assertions
	assert_true(controller.playerLost, "Player should lose when hull hits zero")
	assert_eq(controller.scene_changed_path, "res://Model/ScreenData/LoseScreen.tscn")

	# Cleanup
	player.queue_free()
	controller.queue_free()

func test_Velocity_Loss():
	var controller = TestableGameManager.new()
	add_child(controller)

	# Mock required nodes
	controller.scenarioHeader = Label.new()
	controller.add_child(controller.scenarioHeader)
	controller.UIAnimationPlayer = AnimationPlayer.new()
	controller.add_child(controller.UIAnimationPlayer)

	# Mock player
	var player = MockPlayerVelocity.new()
	add_child(player)
	controller.player = player

	# Trigger loss condition
	controller.playerLost = true

	# Call endPlayerTurn
	controller.endPlayerTurn()

	# Assertions
	assert_true(controller.playerLost, "Player should lose when hull hits zero")
	assert_eq(controller.scene_changed_path, "res://Model/ScreenData/LoseScreen.tscn")

	# Cleanup
	player.queue_free()
	controller.queue_free()
