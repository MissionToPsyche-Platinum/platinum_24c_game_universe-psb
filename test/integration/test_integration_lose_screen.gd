extends GutTest

var main_scene: PackedScene
var main_node: Control

# Load the scene once before all tests
func before_all():
	main_scene = load("res://Model/ScreenData/LoseScreen.tscn")

# Instantiate the scene before each test
func before_each():
	main_node = main_scene.instantiate()
	get_tree().root.add_child(main_node)
	get_tree().current_scene = main_node

# Clean up after each test
func after_each():
	if main_node:
		main_node.queue_free()
		main_node = null

# Recursive helper to safely find nodes by name
func find_node_recursive(root: Node, name: String) -> Node:
	if root.name == name:
		return root
	for child in root.get_children():
		var result = find_node_recursive(child, name)
		if result != null:
			return result
	return null

# Test: pressing "PlayAgainButton" changes the scene
func test_play_again_button_navigation():
	var play_again_button = find_node_recursive(main_node, "PlayAgainButton")
	assert_not_null(play_again_button, "PlayAgainButton should exist for navigation test")

	assert_true(play_again_button is BaseButton, "PlayAgainButton must be a BaseButton")

	# Simulate button press
	play_again_button.pressed.emit()

	# Allow scene transition to process
	await get_tree().process_frame
	await get_tree().process_frame

	# Verify scene changed
	var current_scene = get_tree().current_scene
	assert_ne(
		current_scene,
		main_node,
		"Pressing PlayAgainButton should change the scene"
	)
