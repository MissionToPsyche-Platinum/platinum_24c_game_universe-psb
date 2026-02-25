extends GutTest

var main_scene: PackedScene
var main_node: Control

# -----------------------------
# Setup / Teardown
# -----------------------------

# Load the scene once before all tests
func before_all():
	main_scene = load("res://Model/ScreenData/WinScreen.tscn")
	assert_not_null(main_scene, "Failed to load WinScreen.tscn")

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
	# Ensure any deferred nodes are processed and freed
	await get_tree().process_frame

# -----------------------------
# Helper Functions
# -----------------------------

# Recursive helper to safely find nodes by name
func find_node_recursive(root: Node, name: String) -> Node:
	if root.name == name:
		return root
	for child in root.get_children():
		var result = find_node_recursive(child, name)
		if result != null:
			return result
	return null

# -----------------------------
# Tests
# -----------------------------

# Test: pressing "PlayAgainButton" changes the scene
func test_play_again_button_navigation():
	var play_again = find_node_recursive(main_node, "PlayAgainButton")
	assert_not_null(play_again, "Play Again Button should exist for navigation test")

	# Emit the button pressed signal safely
	play_again.emit_signal("pressed")

	# Wait until the current scene actually changes (max 1 second)
	var timeout = 60  # 60 frames (~1 sec at 60fps)
	while get_tree().current_scene == main_node and timeout > 0:
		await get_tree().process_frame
		timeout -= 1

	assert_true(get_tree().current_scene != main_node, "Pressing Play Again should change the scene")
