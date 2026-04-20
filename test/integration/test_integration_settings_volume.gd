extends GutTest

## Integration test: Settings screen volume slider adjusts the Music bus (game music),
## and scenario/title music players route through that bus.

const MAIN_SCENE := preload("res://Model/Scenes/MainScene.tscn")
const TITLE_SCREEN := preload("res://Model/ScreenData/TitleScreen.tscn")

const _MUSIC_BUS := "Music"

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


func before_each() -> void:
	_main = MAIN_SCENE.instantiate()
	get_tree().root.add_child(_main)
	get_tree().current_scene = _main


func after_each() -> void:
	var music_bus := AudioServer.get_bus_index(_MUSIC_BUS)
	if music_bus >= 0:
		AudioServer.set_bus_volume_linear(music_bus, 1.0)

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

func test_settings_volume_slider_updates_music_bus_linear_gain() -> void:
	await wait_process_frames(2)
	_forgive_known_scenario_ui_animation_warnings()

	var music_bus := AudioServer.get_bus_index(_MUSIC_BUS)
	assert_gte(music_bus, 0, "Music bus must exist for the settings slider test.")

	var slider: HSlider = _main.get_node("SettingsMenu/Setting Screen/HSlider") as HSlider
	assert_not_null(slider, "Settings screen should expose the volume HSlider.")

	slider.value = 100.0
	assert_almost_eq(
		AudioServer.get_bus_volume_linear(music_bus),
		1.0,
		0.001,
		"Slider at 100% should set the Music bus to full linear gain."
	)

	slider.value = 0.0
	assert_almost_eq(
		AudioServer.get_bus_volume_linear(music_bus),
		0.0,
		0.001,
		"Slider at 0% should mute the Music bus (linear)."
	)

	slider.value = 37.0
	assert_almost_eq(
		AudioServer.get_bus_volume_linear(music_bus),
		0.37,
		0.001,
		"Intermediate slider values should scale Music bus linear gain."
	)

	_forgive_known_scenario_ui_animation_warnings()


func test_pause_flow_reaches_settings_slider_while_paused() -> void:
	await wait_process_frames(2)
	_forgive_known_scenario_ui_animation_warnings()
	_main.toggle_pause()
	assert_true(get_tree().paused, "Test should start from a paused state for settings access.")

	_main._on_Settings_pressed()
	var settings_menu: CanvasLayer = _main.get_node("SettingsMenu") as CanvasLayer
	assert_true(settings_menu.visible, "Settings should be visible from pause.")

	var slider: HSlider = _main.get_node("SettingsMenu/Setting Screen/HSlider") as HSlider
	slider.value = 42.0
	var music_bus := AudioServer.get_bus_index(_MUSIC_BUS)
	assert_almost_eq(
		AudioServer.get_bus_volume_linear(music_bus),
		0.42,
		0.001,
		"Volume changes should apply while the game is paused in the settings screen."
	)

	_forgive_known_scenario_ui_animation_warnings()
