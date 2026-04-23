extends GutTest

## System test: Meteor minigame loads through GameManager (same path as real play) and
## completes when the configured survival duration elapses. Default duration is 30 seconds;
## Engine.time_scale accelerates in-game time so the test finishes quickly.

const MAIN_SCENE := preload("res://Model/Scenes/MainScene.tscn")
const METEOR_SCENARIO: PackedScene = preload("res://Model/ScenarioData/Scenarios/MG_MeteorMinigame.tscn")

var _main: Node2D
var _scenario_won: bool
var _saved_time_scale: float = 1.0


func _forgive_known_scenario_ui_animation_warnings() -> void:
	for e in get_errors():
		if not e.is_engine_error():
			continue
		if e.contains_text("track_get_key_count") or e.contains_text("Method/function failed. Returning: false"):
			e.handled = true


func before_each() -> void:
	_scenario_won = false
	_saved_time_scale = Engine.time_scale
	Engine.time_scale = 1.0
	_main = MAIN_SCENE.instantiate()
	get_tree().root.add_child(_main)
	get_tree().current_scene = _main


func after_each() -> void:
	Engine.time_scale = _saved_time_scale

	if GameManager.scenario != null and is_instance_valid(GameManager.scenario):
		if GameManager.scenario.is_connected("scenarioWon", Callable(GameManager, "endScenario")):
			GameManager.scenario.disconnect("scenarioWon", Callable(GameManager, "endScenario"))
		if GameManager.scenario.is_connected("endScenarioTurn", Callable(GameManager, "endScenarioTurn")):
			GameManager.scenario.disconnect("endScenarioTurn", Callable(GameManager, "endScenarioTurn"))
		GameManager.scenario.queue_free()
	GameManager.scenario = null

	if is_instance_valid(GameManager.stats):
		GameManager.stats.queue_free()
	GameManager.stats = null

	if is_instance_valid(_main):
		_main.queue_free()
	_main = null

	GameManager.player = null
	GameManager.card_manager = null
	GameManager.map = null
	GameManager.UI = null
	GameManager.handController = null
	GameManager.UIAnimationPlayer = null
	GameManager.playerInstantiated = false

	await get_tree().process_frame


func test_meteor_minigame_default_survival_is_thirty_seconds() -> void:
	var script_minigame: MeteorMinigame = MeteorMinigame.new()
	assert_eq(script_minigame.survival_time, 30.0,
		"Meteor minigame should default to a 30 second survival window.")
	script_minigame.free()


func test_meteor_minigame_completes_after_survival_duration_via_gamemanager() -> void:
	await wait_process_frames(2)
	assert_not_null(GameManager.player, "MainScene should register GameManager.player before loading scenarios.")

	GameManager.loadScenario(METEOR_SCENARIO)
	await wait_process_frames(2)
	_forgive_known_scenario_ui_animation_warnings()

	var scenario_root: Node = GameManager.scenario
	assert_not_null(scenario_root, "loadScenario should assign GameManager.scenario.")
	assert_true(scenario_root is MeteorMinigame, "Loaded scenario should be MeteorMinigame.")

	var meteor: MeteorMinigame = scenario_root as MeteorMinigame
	assert_eq(meteor.survival_time, 30.0, "Loaded Meteor minigame should keep the 30 second survival export.")

	if scenario_root.is_connected("scenarioWon", Callable(GameManager, "endScenario")):
		scenario_root.disconnect("scenarioWon", Callable(GameManager, "endScenario"))
	scenario_root.scenarioWon.connect(_on_scenario_won_meteor)

	# _process delta is scaled by Engine.time_scale, so 30s of in-game elapsed time passes in a fraction of real time.
	# GUT's wait_until also accumulates scaled delta, so max_time must stay above the survival duration (30s game time).
	Engine.time_scale = 100.0

	var completed: bool = await wait_until(
		func() -> bool: return _scenario_won,
		120.0,
		0.02,
		"Meteor minigame should emit scenarioWon after 30 seconds of scaled game time."
	)
	assert_true(completed, "Timed out waiting for Meteor win signal.")
	assert_true(_scenario_won, "scenarioWon should have fired after the survival duration.")
	_forgive_known_scenario_ui_animation_warnings()


func _on_scenario_won_meteor() -> void:
	_scenario_won = true
