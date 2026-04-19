extends GutTest

var main_scene: PackedScene
var main_node: Control

func before_all():
	main_scene = load("res://Model/ScreenData/TitleScreen.tscn")

func before_each():
	main_node = main_scene.instantiate()
	get_tree().root.add_child(main_node)  # attach to running scene tree
	get_tree().current_scene = main_node  # ensures get_tree() works in TitleScreen.gd

func after_each():
	if is_instance_valid(main_node):
		main_node.queue_free()
	main_node = null

func test_start_button_navigation():
	var start_button = main_node.get_node_or_null("MainMenu/StartGameLabel/StartButton")
	assert_not_null(start_button, "Start button should exist for navigation test")

	start_button.pressed.emit()

	await get_tree().process_frame

	var current_scene = get_tree().current_scene
	assert_true(current_scene != main_node, "Pressing Start should change the scene")
