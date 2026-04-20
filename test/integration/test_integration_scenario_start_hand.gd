extends GutTest

## Integration test: when a scenario loads, the player draws a fixed-size opening hand
## of protocol cards taken from their deck (possessed PackedScenes), via `getNewHand()`.

const HandControllerScript = preload("res://Model/Scenes/HandController.gd")
const ProtocolCard = preload("res://Model/CardData/BaseCardData/protocol_card_base.gd")

const SCENARIO_PATH := "res://Model/ScenarioData/Scenarios/Sc_DoubleDarkMatter.tscn"

const CARD_A := preload("res://Model/CardData/Cards/SUPER_AWESOME_CARD.tscn")
const CARD_B := preload("res://Model/CardData/Cards/HyperEvolvedGoldfish.tscn")
const CARD_C := preload("res://Model/CardData/Cards/SameRevolutionDeliver.tscn")
const CARD_D := preload("res://Model/CardData/Cards/ForgotSomething.tscn")
const CARD_E := preload("res://Model/CardData/Cards/QuantumCoinFliptscn.tscn")
const CARD_F := preload("res://Model/CardData/Cards/RedundantEngineering.tscn")

class MockAnimationPlayer:
	func play(_anim_name: String) -> void:
		pass

	func stop() -> void:
		pass

	func seek(_pos: float, _update: bool = false) -> void:
		pass


class MockDrawCardPreview extends DrawCardPreview:
	func drawCardPreview(_card: PackedScene) -> void:
		pass


## Deck order is preserved (no shuffle) so the first N draws match the first N scenes.
class DeterministicPlayer:
	extends Player

	func instantiatePlayerDeck() -> void:
		deck = GameManager.card_manager.getDefaultDeck()


var _saved_player: Player
var _saved_card_manager: CardManager
var _saved_scenario: Node
var _saved_ui: Control
var _saved_ui_anim: Node
var _saved_hand_controller: HandController
var _saved_draw_preview: Node
var _saved_player_instantiated: bool

var _player: DeterministicPlayer
var _card_manager: CardManager
var _hand_controller: HandController


func before_each() -> void:
	_saved_player = GameManager.player
	_saved_card_manager = GameManager.card_manager
	_saved_scenario = GameManager.scenario
	_saved_ui = GameManager.UI
	_saved_ui_anim = GameManager.UIAnimationPlayer
	_saved_hand_controller = GameManager.handController
	_saved_draw_preview = GameManager.drawCardPreview
	_saved_player_instantiated = GameManager.playerInstantiated

	GameManager.scenario = null
	GameManager.playerInstantiated = false

	_card_manager = CardManager.new()
	_card_manager.defaultDeck = [CARD_A, CARD_B, CARD_C, CARD_D, CARD_E, CARD_F]

	_player = DeterministicPlayer.new()
	_player.defaultCard = CARD_E

	_hand_controller = HandControllerScript.new()
	_hand_controller.test_mode = true
	_hand_controller.card_container = Control.new()
	_hand_controller.add_child(_hand_controller.card_container)
	_hand_controller.cardEffectLabel = Label.new()
	_hand_controller.add_child(_hand_controller.cardEffectLabel)
	_hand_controller.continueScenarioControl = Control.new()
	_hand_controller.add_child(_hand_controller.continueScenarioControl)

	var ui := Control.new()
	var hand_container := Control.new()
	hand_container.name = "Hand Container"
	var response_label := Label.new()
	response_label.name = "Response Label"
	hand_container.add_child(response_label)
	ui.add_child(hand_container)

	GameManager.player = _player
	GameManager.card_manager = _card_manager
	GameManager.handController = _hand_controller
	GameManager.drawCardPreview = MockDrawCardPreview.new()
	GameManager.UIAnimationPlayer = MockAnimationPlayer.new()
	GameManager.UI = ui
	GameManager.scenarioHeader = Label.new()
	GameManager.scenarioEffectLabel = Label.new()
	GameManager.scenarioWinConditionsLabel = Label.new()

	get_tree().root.add_child(_player)
	get_tree().root.add_child(_hand_controller)


func after_each() -> void:
	if GameManager.scenario != null and is_instance_valid(GameManager.scenario):
		if GameManager.scenario.is_connected("scenarioWon", Callable(GameManager, "endScenario")):
			GameManager.scenario.disconnect("scenarioWon", Callable(GameManager, "endScenario"))
		if GameManager.scenario.is_connected("endScenarioTurn", Callable(GameManager, "endScenarioTurn")):
			GameManager.scenario.disconnect("endScenarioTurn", Callable(GameManager, "endScenarioTurn"))
		GameManager.scenario.queue_free()
	GameManager.scenario = null

	if is_instance_valid(_hand_controller):
		_hand_controller.queue_free()
	if is_instance_valid(_player):
		_player.queue_free()

	GameManager.player = _saved_player if is_instance_valid(_saved_player) else null
	GameManager.card_manager = _saved_card_manager if is_instance_valid(_saved_card_manager) else null
	GameManager.scenario = _saved_scenario if is_instance_valid(_saved_scenario) else null
	GameManager.UI = _saved_ui if is_instance_valid(_saved_ui) else null
	GameManager.UIAnimationPlayer = _saved_ui_anim if is_instance_valid(_saved_ui_anim) else null
	GameManager.handController = _saved_hand_controller if is_instance_valid(_saved_hand_controller) else null
	GameManager.drawCardPreview = _saved_draw_preview if is_instance_valid(_saved_draw_preview) else null
	GameManager.playerInstantiated = _saved_player_instantiated

	GameManager.scenarioHeader = null
	GameManager.scenarioEffectLabel = null
	GameManager.scenarioWinConditionsLabel = null

	_hand_controller = null
	_player = null
	_card_manager = null

	await get_tree().process_frame


func test_scenario_start_draws_beginning_hand_from_player_deck() -> void:
	var expected_deck: Array[PackedScene] = [CARD_A, CARD_B, CARD_C, CARD_D, CARD_E, CARD_F]
	var opening_count: int = _player.BEGINNING_DECK_SIZE

	await GameManager.loadScenario(SCENARIO_PATH)

	assert_eq(
		_player.hand.size(),
		opening_count,
		"Opening hand should contain BEGINNING_DECK_SIZE cards from the player's deck."
	)
	assert_eq(
		_hand_controller.cards.size(),
		opening_count,
		"Hand UI should receive one node per card drawn for the opening hand."
	)

	for i in range(opening_count):
		assert_eq(
			_player.hand[i],
			expected_deck[i],
			"Opening hand should take the next protocol cards from the deck (deterministic order)."
		)
		assert_true(
			_hand_controller.cards[i] is ProtocolCard,
			"Hand UI nodes should instantiate protocol cards."
		)

	assert_eq(
		_player.deck.size(),
		expected_deck.size() - opening_count,
		"Remaining deck should shrink by the number of cards moved into the hand."
	)

	var pool: Array = expected_deck.duplicate()
	for scene in _player.hand:
		assert_true(pool.has(scene), "Hand cards should come from the player's possessed deck.")
