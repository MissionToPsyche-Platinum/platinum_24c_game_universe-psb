extends GutTest

var _title_packed: PackedScene
var _title_root: Control


func _tutorial_loaded_from_title_flow() -> bool:
	return GameManager.tutorialMode and GameManager.tutorialScenario != null


func _forgive_known_tutorial_animation_warnings() -> void:
	# Tutorial defers AnimationPlayer.play to the next frame; Godot may still log
	# mixer warnings that do not affect gameplay.
	for e in get_errors():
		if not e.is_engine_error():
			continue
		if e.contains_text("track_get_key_count") or e.contains_text("Method/function failed. Returning: false"):
			e.handled = true


func before_all() -> void:
	_title_packed = load("res://Model/ScreenData/TitleScreen.tscn")


func before_each() -> void:
	GameManager.tutorialMode = false
	GameManager.tutorialScenario = null
	_title_root = _title_packed.instantiate()
	get_tree().root.add_child(_title_root)
	get_tree().current_scene = _title_root


func after_each() -> void:
	if is_instance_valid(_title_root):
		_title_root.queue_free()
	var cs := get_tree().current_scene
	if is_instance_valid(cs) and cs.name == "TutorialScenario":
		cs.queue_free()
		await get_tree().process_frame
	GameManager.tutorialMode = false
	GameManager.tutorialScenario = null


func test_tutorial_can_be_played_from_title_screen() -> void:
	var tutorial_button: Button = _title_root.get_node_or_null(
		"MainMenu/TutorialLabel/TutorialButton")
	assert_not_null(tutorial_button, "Title screen should expose a Tutorial button")

	tutorial_button.emit_signal("pressed")
	var loaded: bool = await wait_until(_tutorial_loaded_from_title_flow, 15.0,
		"Tutorial scenario should load after pressing Tutorial from the title screen")
	assert_true(loaded, "Timed out waiting for tutorial to load from title screen")
	assert_true(GameManager.tutorialMode, "GameManager should mark tutorial mode after tutorial loads")
	assert_true(GameManager.tutorialScenario is TutorialScenario, "GameManager should reference the live TutorialScenario")
	await wait_process_frames(2)
	_forgive_known_tutorial_animation_warnings()
