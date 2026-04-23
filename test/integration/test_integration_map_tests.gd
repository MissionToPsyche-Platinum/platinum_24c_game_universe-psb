extends GutTest

var map: MapController


func _forgive_known_engine_animation_warnings() -> void:
	for e in get_errors():
		if not e.is_engine_error():
			continue
		if (
			e.contains_text("track_get_key_count")
			or e.contains_text("Method/function failed. Returning: false")
			or e.contains_text("Method/function failed. Returning: nullptr")
		):
			e.handled = true


# -------------------------
# SETUP
# -------------------------
func before_each():
	var scene: PackedScene = load("res://Model/Scenes/Map/map.tscn")
	map = scene.instantiate()
	add_child_autofree(map)

	map.initialize_with_layout(
		load("res://Model/MapData/Maps/Extra/Map_3Nodes.tres")
	)

	await get_tree().process_frame
	await get_tree().process_frame


# -------------------------
# TEARDOWN
# -------------------------
func after_each():
	if map:
		map.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
		map = null

	_forgive_known_engine_animation_warnings()


# -------------------------
# TEST 1: movement
# -------------------------
func test_move_to_new_scenario():
	var model := map.model
	var view := map.view

	var start_index := model.current_index
	var neighbors := model.get_proceeding_neighbors(start_index)

	assert_gt(neighbors.size(), 0, "Start node should have neighbors")

	var target_index := neighbors[0]

	map.map_active = true
	map._on_node_clicked(target_index)

	assert_eq(
		model.psyche_anticipated_index,
		target_index,
		"Model should anticipate movement"
	)

	map.advance_position()

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(
		model.current_index,
		target_index,
		"Model should update current index"
	)

	# ✅ FIX: DO NOT convert coordinates
	var actual_pos: Vector2 = view.psyche_view.position
	var expected_pos: Vector2 = model.layout.node_positions[target_index]

	assert_true(
		actual_pos.is_equal_approx(expected_pos),
		"Psyche view should move to target node"
	)

	assert_true(
		map.visible,
		"Map should be visible after advancing position"
	)

	_forgive_known_engine_animation_warnings()


# -------------------------
# TEST 2: inactive interaction
# -------------------------
func test_during_choose_reward():
	var model := map.model

	map.map_active = false
	map.visible = false

	var start_index := model.current_index
	var neighbors := model.get_proceeding_neighbors(start_index)

	assert_gt(neighbors.size(), 0, "Start node should have neighbors")

	var target_index := neighbors[0]

	map._on_node_clicked(target_index)
	await get_tree().process_frame

	assert_eq(
		model.psyche_anticipated_index,
		-1,
		"Movement should NOT be registered while map inactive"
	)

	assert_false(
		map.visible,
		"Map should remain invisible"
	)
