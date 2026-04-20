extends GutTest

## Integration test: MainScene pause halts normal scene processing, shows the pause UI,
## exposes settings from the pause flow, and resume restores gameplay processing.

const MAIN_SCENE := preload("res://Model/Scenes/MainScene.tscn")

var _main: Node2D


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


## Default-process-mode node: increments while the scene tree runs and is not paused.
class _ProcessTickProbe:
	extends Node
	var ticks := 0

	func _process(_delta: float) -> void:
		ticks += 1


func before_each() -> void:
	_main = MAIN_SCENE.instantiate()
	get_tree().root.add_child(_main)
	get_tree().current_scene = _main


func after_each() -> void:
	get_tree().paused = false
	_forgive_known_scenario_ui_animation_warnings()

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


func test_pause_halts_background_processing_shows_pause_ui_settings_and_resume_restores() -> void:
	await wait_process_frames(2)
	_forgive_known_scenario_ui_animation_warnings()
	assert_not_null(GameManager.player, "MainScene should register GameManager.player in _ready.")

	var probe := _ProcessTickProbe.new()
	_main.add_child(probe)

	await wait_process_frames(4)
	assert_gt(probe.ticks, 0, "Background _process should run while the game is not paused.")

	var ticks_before_pause := probe.ticks
	_main.toggle_pause()

	assert_true(get_tree().paused, "toggle_pause should set the scene tree to paused.")
	var pause_menu: CanvasLayer = _main.get_node("PauseMenu") as CanvasLayer
	assert_true(pause_menu.visible, "Pause menu layer should be visible when paused.")

	var pause_title: Label = _main.get_node("PauseMenu/Pause Screen/Label") as Label
	assert_eq(pause_title.text, "Game Paused", "Pause screen should show the paused-state title.")

	await wait_process_frames(6)
	assert_eq(
		probe.ticks,
		ticks_before_pause,
		"Normal scene _process should halt while the tree is paused (background activity stopped)."
	)

	var settings_menu: CanvasLayer = _main.get_node("SettingsMenu") as CanvasLayer
	_main._on_Settings_pressed()
	assert_true(settings_menu.visible, "Settings should be reachable while paused.")
	assert_false(pause_menu.visible, "Opening settings should hide the pause overlay until back.")

	_main._on_SettingsBackButton_pressed()
	assert_false(settings_menu.visible, "Back from settings should return to the pause overlay.")
	assert_true(pause_menu.visible, "Pause menu should be visible again after leaving settings.")
	assert_true(get_tree().paused, "Game should remain paused while browsing settings.")

	await wait_process_frames(4)
	assert_eq(
		probe.ticks,
		ticks_before_pause,
		"Background processing should stay halted while still paused (including settings flow)."
	)

	_main._on_Resume_pressed()
	assert_false(get_tree().paused, "Resume should unpause the scene tree.")
	assert_false(pause_menu.visible, "Resume should hide the pause menu.")

	var ticks_after_resume := probe.ticks
	await wait_process_frames(4)
	assert_gt(
		probe.ticks,
		ticks_after_resume,
		"After resume, normal _process should run again (gameplay processing restored)."
	)

	_forgive_known_scenario_ui_animation_warnings()
	probe.queue_free()
	_forgive_known_scenario_ui_animation_warnings()


func test_main_scene_input_handles_pause_action_event() -> void:
	## _input uses event.is_action_pressed("pause"); deliver the same event type the engine uses.
	await wait_process_frames(2)
	_forgive_known_scenario_ui_animation_warnings()
	assert_false(get_tree().paused, "Test should start unpaused.")

	var ev := InputEventAction.new()
	ev.action = "pause"
	ev.pressed = true
	_main._input(ev)

	assert_true(get_tree().paused, "Pause action event should toggle the tree into a paused state.")
	var pause_menu: CanvasLayer = _main.get_node("PauseMenu") as CanvasLayer
	assert_true(pause_menu.visible, "Pause menu should appear after the pause action is handled.")

	_main._on_Resume_pressed()
	_forgive_known_scenario_ui_animation_warnings()
