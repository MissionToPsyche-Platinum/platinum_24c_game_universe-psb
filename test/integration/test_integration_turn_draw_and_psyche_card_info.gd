extends GutTest

## Integration: after a scenario turn completes, the next player turn begins with a draw from the
## player's deck (possessed PackedScenes). If deck and hand are both empty, the configured default
## card is used. Psyche-mission-inspired protocol cards expose optional extra info via ProtocolCard.

const HandControllerScript = preload("res://Model/Scenes/HandController.gd")
const ProtocolCard = preload("res://Model/CardData/BaseCardData/protocol_card_base.gd")
const DefaultBehavior = preload("res://Model/CardData/CardBehaviorData/DefaultBehavior.gd")

const SCENARIO_PATH: PackedScene = preload("res://Model/ScenarioData/Scenarios/Sc_DoubleDarkMatter.tscn")

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
var _saved_tutorial_mode: bool

var _player: DeterministicPlayer
var _card_manager: CardManager
var _hand_controller: HandController


func _forgive_known_scenario_ui_animation_warnings() -> void:
	## Godot may log `track_get_key_count` when an Animation has empty tracks; MainScene/UI tests hit this.
	for e in get_errors():
		if not e.is_engine_error():
			continue
		if (
			e.contains_text("track_get_key_count")
			or e.contains_text("Method/function failed. Returning: false")
			or e.contains_text("Method/function failed. Returning: nullptr")
		):
			e.handled = true


func before_each() -> void:
	_saved_player = GameManager.player
	_saved_card_manager = GameManager.card_manager
	_saved_scenario = GameManager.scenario
	_saved_ui = GameManager.UI
	_saved_ui_anim = GameManager.UIAnimationPlayer
	_saved_hand_controller = GameManager.handController
	_saved_draw_preview = GameManager.drawCardPreview
	_saved_player_instantiated = GameManager.playerInstantiated
	_saved_tutorial_mode = GameManager.tutorialMode

	GameManager.scenario = null
	GameManager.playerInstantiated = false
	GameManager.tutorialMode = false

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
	_forgive_known_scenario_ui_animation_warnings()
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
	GameManager.tutorialMode = _saved_tutorial_mode

	GameManager.scenarioHeader = null
	GameManager.scenarioEffectLabel = null
	GameManager.scenarioWinConditionsLabel = null

	_hand_controller = null
	_player = null
	_card_manager = null

	await get_tree().process_frame


func test_end_of_scenario_turn_draws_next_card_from_player_deck() -> void:
	var expected_deck: Array[PackedScene] = [CARD_A, CARD_B, CARD_C, CARD_D, CARD_E, CARD_F]
	var opening_count: int = _player.BEGINNING_DECK_SIZE

	await GameManager.loadScenario(SCENARIO_PATH)

	assert_eq(_player.deck.size(), expected_deck.size() - opening_count, "One card should remain after the opening hand.")

	await GameManager.endScenarioTurn()
	_forgive_known_scenario_ui_animation_warnings()

	assert_eq(
		_player.hand.size(),
		opening_count + 1,
		"Beginning a new player turn should draw one more card from the player's deck."
	)
	assert_eq(_player.hand[opening_count], CARD_F, "The draw should take the next possessed card from the deck.")
	assert_eq(_hand_controller.cards.size(), _player.hand.size(), "Hand UI should stay in sync with the player's hand.")


func test_when_deck_and_hand_empty_draw_uses_default_card() -> void:
	await GameManager.loadScenario(SCENARIO_PATH)

	_player.deck.clear()
	_player.hand.clear()
	for c in _hand_controller.cards.duplicate():
		_hand_controller.removeCard(c)
	await get_tree().process_frame

	_player.beginPlayerTurn()
	_forgive_known_scenario_ui_animation_warnings()

	assert_eq(_player.hand.size(), 1, "A draw with no deck and no hand should still add the default card.")
	assert_eq(
		_player.hand[0].resource_path,
		_player.defaultCard.resource_path,
		"The default PackedScene should be used when the player must draw with an empty deck and hand."
	)

	var drawn: ProtocolCard = _hand_controller.cards[0] as ProtocolCard
	assert_true(drawn != null, "Default draw should instantiate a protocol card in the hand UI.")
	assert_eq(drawn.cardBehavior.size(), 1, "Bailout draw should inject behavior for the default card.")
	assert_true(drawn.cardBehavior[0] is DefaultBehavior, "Bailout path should apply DefaultBehavior.")


func test_psyche_mission_card_exposes_optional_extra_information() -> void:
	# Opening hand consumes the first BEGINNING_DECK_SIZE cards; keep ForgotSomething for the
	# first draw at the next player turn only (Psyche-inspired card).
	_card_manager.defaultDeck = [CARD_A, CARD_B, CARD_C, CARD_E, CARD_F, CARD_D]

	await GameManager.loadScenario(SCENARIO_PATH)
	await GameManager.endScenarioTurn()
	_forgive_known_scenario_ui_animation_warnings()

	var psyche_card: ProtocolCard = null
	for node in _hand_controller.cards:
		var pc := node as ProtocolCard
		if pc and pc.get_meta("source_scene", null) == CARD_D:
			psyche_card = pc
			break

	assert_true(psyche_card != null, "ForgotSomething should appear in the hand after the turn-start draw.")
	assert_true(psyche_card.hasExtraInfo, "Psyche-inspired cards should flag optional extra mission information.")
	assert_ne(psyche_card.extraInfoHeaderString.strip_edges(), "", "Extra info should include a header the player can read.")
	assert_ne(psyche_card.extraInfoBodyString.strip_edges(), "", "Extra info should include body text the player can read.")

	assert_true(psyche_card.extraInfoButton.visible, "The extra-info affordance should be visible when the card loads.")

	psyche_card.toggleExtraInfo()
	assert_true(psyche_card.extraInfoHolder.visible, "Player can choose to view the extra mission information.")
	assert_true(psyche_card.showingExtraInfo, "Toggle should track that extra info is visible.")

	psyche_card.toggleExtraInfo()
	assert_false(psyche_card.extraInfoHolder.visible, "Player can dismiss the optional mission information.")
