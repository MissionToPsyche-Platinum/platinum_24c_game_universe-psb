extends GutTest

## System test: Shooting minigame loads through GameManager (same path as real play) and
## completes when the UFO enemy is destroyed (scenarioWon).

const MAIN_SCENE := preload("res://Model/Scenes/MainScene.tscn")
const SHOOTING_SCENARIO := "res://Model/ScenarioData/Scenarios/MG_ShootingMinigame.tscn"

var _main: Node2D
var _scenario_won: bool


func _forgive_known_scenario_ui_animation_warnings() -> void:
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


func test_shooting_minigame_default_enemies_export_is_one() -> void:
	var sm: ShootingMinigame = ShootingMinigame.new()
	assert_eq(sm.enemies, 1, "Shooting minigame should default to one enemy for win.")
	sm.free()


func test_shooting_minigame_completes_when_enemy_destroyed_via_gamemanager() -> void:
	await wait_process_frames(2)
	assert_not_null(GameManager.player, "MainScene should register GameManager.player before loading scenarios.")

	GameManager.loadScenario(SHOOTING_SCENARIO)
	await wait_process_frames(4)
	_forgive_known_scenario_ui_animation_warnings()

	var scenario_root: Node = GameManager.scenario
	assert_not_null(scenario_root, "loadScenario should assign GameManager.scenario.")
	assert_true(scenario_root is ShootingMinigame, "Loaded scenario should be ShootingMinigame.")

	if scenario_root.is_connected("scenarioWon", Callable(GameManager, "endScenario")):
		scenario_root.disconnect("scenarioWon", Callable(GameManager, "endScenario"))
	scenario_root.scenarioWon.connect(_on_scenario_won_shooting)

	var ufo: Node = get_tree().get_first_node_in_group("UFO")
	assert_not_null(ufo, "Shooting scenario should spawn a UFO in group UFO.")
	assert_true(ufo.has_method("eliminated"), "UFO should support elimination.")

	ufo.disable_ai = true
	ufo.set_process(false)
	ufo.set_physics_process(false)

	ufo.eliminated()

	var completed: bool = await wait_until(
		func() -> bool: return _scenario_won,
		10.0,
		0.05,
		"Shooting minigame should emit scenarioWon when the enemy is destroyed."
	)
	assert_true(completed, "Timed out waiting for Shooting minigame win signal.")
	assert_true(_scenario_won, "scenarioWon should have fired after the enemy was destroyed.")
	_forgive_known_scenario_ui_animation_warnings()


func _on_scenario_won_shooting() -> void:
	_scenario_won = true
