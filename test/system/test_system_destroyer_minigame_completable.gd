extends GutTest

## System test: Destroyer loads through the same GameManager path as gameplay (MainScene wiring)
## and can be won by clearing all bricks.

const MAIN_SCENE := preload("res://Model/Scenes/MainScene.tscn")
const DESTROYER_SCENARIO := "res://Model/ScenarioData/Scenarios/MG_DestroyerMinigame.tscn"

var _main: Node2D
var _scenario_won: bool


func _forgive_known_scenario_ui_animation_warnings() -> void:
	# loadScenario resets and plays GUI animations; Godot may log mixer/track warnings
	# that do not affect gameplay (same pattern as the title→tutorial system test).
	for e in get_errors():
		if not e.is_engine_error():
			continue
		if e.contains_text("track_get_key_count") or e.contains_text("Method/function failed. Returning: false"):
			e.handled = true


func before_each() -> void:
	_scenario_won = false
	_main = MAIN_SCENE.instantiate()
	get_tree().root.add_child(_main)
	get_tree().current_scene = _main


func after_each() -> void:
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


func test_destroyer_minigame_can_complete_via_gamemanager() -> void:
	await wait_process_frames(2)
	assert_not_null(GameManager.player, "MainScene should register GameManager.player before loading scenarios.")

	GameManager.loadScenario(DESTROYER_SCENARIO)
	await wait_process_frames(2)
	_forgive_known_scenario_ui_animation_warnings()

	var scenario_root: Node = GameManager.scenario
	assert_not_null(scenario_root, "loadScenario should assign GameManager.scenario.")
	assert_true(scenario_root is DestroyerMinigame, "Loaded scenario should be DestroyerMinigame.")

	# Isolate minigame win from full scenario-outro / reward flow (still validates real loadScenario wiring).
	if scenario_root.is_connected("scenarioWon", Callable(GameManager, "endScenario")):
		scenario_root.disconnect("scenarioWon", Callable(GameManager, "endScenario"))
	scenario_root.scenarioWon.connect(_on_scenario_won_destroyer)

	var bricks: Array = scenario_root.get_children().filter(
		func(child: Node) -> bool: return child.has_method("destroy")
	)
	assert_gt(bricks.size(), 0, "Destroyer should spawn at least one brick.")

	for brick in bricks:
		(brick as Node).destroy()

	var completed: bool = await wait_until(
		func() -> bool: return _scenario_won,
		10.0,
		0.05,
		"Destroyer should emit scenarioWon when the last brick is cleared."
	)
	assert_true(completed, "Timed out waiting for Destroyer win signal.")
	assert_true(_scenario_won, "scenarioWon should have fired after all bricks were destroyed.")
	_forgive_known_scenario_ui_animation_warnings()


func _on_scenario_won_destroyer() -> void:
	_scenario_won = true
