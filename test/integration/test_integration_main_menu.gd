extends GutTest

# --- Mock Players for testing ---
class MockPlayerHull:
	extends Player
	func _ready():
		hullIntegrity = 0
		power = 50
		velocity = 50
	func getNewHand(): pass
	func beginPlayerTurn(): pass
	func returnAllCards(): pass

class MockPlayerPower:
	extends Player
	func _ready():
		hullIntegrity = 50
		power = 0
		velocity = 50
	func getNewHand(): pass
	func beginPlayerTurn(): pass
	func returnAllCards(): pass

class MockPlayerVelocity:
	extends Player
	func _ready():
		hullIntegrity = 50
		power = 50
		velocity = 0
	func getNewHand(): pass
	func beginPlayerTurn(): pass
	func returnAllCards(): pass

class MockPlayerForRewards:
	extends Player
	func _ready():
		deck.clear()
	func getNewHand(): pass
	func beginPlayerTurn(): pass
	func returnAllCards(): pass

# --- Mock CardManager ---
class MockCardManager:
	extends CardManager
	func _ready():
		bank.clear()
	func getReward():
		return []

# --- Mock AnimationPlayer ---
class MockAnimationPlayer:
	func play(anim_name: String) -> void: pass
	func stop() -> void: pass
	func is_playing() -> bool: return false

# --- Testable GameManager ---
class TestableGameManager:
	extends "res://Controller/GameManager.gd"
	var scene_changed_path: String = ""
	func change_scene_to_file(path: String) -> void:
		scene_changed_path = path

# --- Hand Rotation Tests ---
func test_rotate_left():
	var HandScript = load("res://Model/Scenes/HandController.gd")
	var hand = HandScript.new()
	hand.test_mode = true
	get_tree().root.add_child(hand)

	hand.card_container = Control.new()
	hand.add_child(hand.card_container)
	hand.cardEffectLabel = Label.new()
	hand.add_child(hand.cardEffectLabel)
	hand.continueScenarioControl = Control.new()
	hand.add_child(hand.continueScenarioControl)

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

	hand.card_container = Control.new()
	hand.add_child(hand.card_container)
	hand.cardEffectLabel = Label.new()
	hand.add_child(hand.cardEffectLabel)
	hand.continueScenarioControl = Control.new()
	hand.add_child(hand.continueScenarioControl)

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

# --- Player Loss Tests ---
func test_Hull_Loss():
	var controller = TestableGameManager.new()
	add_child(controller)
	controller.scenarioHeader = Label.new()
	controller.add_child(controller.scenarioHeader)

	controller.UIAnimationPlayer = MockAnimationPlayer.new()

	var player = MockPlayerHull.new()
	add_child(player)
	controller.player = player

	controller.playerLost = true
	controller.endPlayerTurn()

	assert_true(controller.playerLost)
	assert_eq(controller.scene_changed_path, "res://Model/ScreenData/LoseScreen.tscn")
	player.queue_free()
	controller.queue_free()

func test_Power_Loss():
	var controller = TestableGameManager.new()
	add_child(controller)
	controller.scenarioHeader = Label.new()
	controller.add_child(controller.scenarioHeader)

	controller.UIAnimationPlayer = MockAnimationPlayer.new()

	var player = MockPlayerPower.new()
	add_child(player)
	controller.player = player

	controller.playerLost = true
	controller.endPlayerTurn()

	assert_true(controller.playerLost)
	assert_eq(controller.scene_changed_path, "res://Model/ScreenData/LoseScreen.tscn")
	player.queue_free()
	controller.queue_free()

func test_Velocity_Loss():
	var controller = TestableGameManager.new()
	add_child(controller)
	controller.scenarioHeader = Label.new()
	controller.add_child(controller.scenarioHeader)

	controller.UIAnimationPlayer = MockAnimationPlayer.new()

	var player = MockPlayerVelocity.new()
	add_child(player)
	controller.player = player

	controller.playerLost = true
	controller.endPlayerTurn()

	assert_true(controller.playerLost)
	assert_eq(controller.scene_changed_path, "res://Model/ScreenData/LoseScreen.tscn")
	player.queue_free()
	controller.queue_free()

# --- Reward Test ---
func test_reward_chosen_adds_card_to_player_deck():
	var controller = TestableGameManager.new()
	add_child(controller)

	var player = MockPlayerForRewards.new()
	controller.player = player
	controller.card_manager = MockCardManager.new()

	var fake_packed_scene = PackedScene.new()
	controller.rewards = [fake_packed_scene]

	controller.UIAnimationPlayer = MockAnimationPlayer.new()

	controller.rewardsHolder = HBoxContainer.new()
	controller.rewardsHolder.visible = true
	add_child(controller.rewardsHolder)

	controller.UI = Control.new()
	add_child(controller.UI)

	var reward_control = Control.new()
	reward_control.name = "RewardControl"
	var reward_label = Label.new()
	reward_label.name = "Reward Label"
	reward_control.add_child(reward_label)
	controller.UI.add_child(reward_control)

	var reward_card = Control.new()
	reward_card.set_meta("source_scene", fake_packed_scene)

	controller.rewardChosen(reward_card)

	assert_eq(player.deck.size(), 1)
	assert_eq(player.deck[0], fake_packed_scene)
	assert_false(controller.rewardsHolder.visible)
	assert_eq(controller.card_manager.bank.size(), 0)

	controller.queue_free()
