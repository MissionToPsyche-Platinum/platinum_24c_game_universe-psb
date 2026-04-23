extends GutTest

var map: MapController


func before_each():
	var scene: PackedScene = load("res://Model/Scenes/Map/map.tscn")
	map = scene.instantiate()
	map.layout = load("res://Model/MapData/Maps/Extra/Map_12Nodes_Scroll.tres")
	add_child(map)

	await get_tree().process_frame


func after_each():
	map.queue_free()

# test if scroll button works for scrollable maps
func test_scroll_button_behavior():
	# Ensure layout is scrollable
	map.layout.is_scrollable = true
	
	# Re-run ready logic manually (since layout changed)
	#map._ready()
	map.map_active = true
	await get_tree().process_frame

	var original_pos := map.view.position.y

	# Create fake mouse click event
	var click := InputEventMouseButton.new()
	click.pressed = true
	click.button_index = MOUSE_BUTTON_LEFT

	map._on_scroll_button_input_event(null, click, 0)
	await get_tree().process_frame

	assert_ne(
		map.view.position.y,
		original_pos,
		"View Y position should change when scroll button pressed"
	)

	var scrolled_pos := map.view.position.y

	# Click again → should toggle back
	map._on_scroll_button_input_event(null, click, 0)
	await get_tree().process_frame

	assert_eq(
		map.view.position.y,
		original_pos,
		"View Y position should toggle back on second press"
	)

	assert_true(
		map.map_active,
		"Map should be active after scroll completes"
	)
