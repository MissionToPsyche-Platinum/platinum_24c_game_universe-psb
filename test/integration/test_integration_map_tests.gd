extends GutTest

var map: MapController


func before_each():
	var scene: PackedScene = load("res://Model/Scenes/Map/map.tscn")
	map = scene.instantiate()
	# Map_3Nodes: the first step from start lands on the node before the asteroid,
	# which satisfies the "reached end" win check — psyche never moves and the map hides.
	map.layout = load("res://Model/MapData/Maps/Map_8Nodes.tres")
	add_child(map)

	await get_tree().process_frame


func after_each():
	map.queue_free()

# test movement to new scenario after scenario completion
func test_move_to_new_scenario():
	var model := map.model
	var view := map.view
	
	var start_index := model.current_index
	var neighbors := model.get_proceeding_neighbors(start_index)

	assert_gt(neighbors.size(), 0, "Start node should have neighbors")

	var target_index := neighbors[0]

	# Simulate clicking node via controller
	map.map_active = true
	map._on_node_clicked(target_index)

	# Model should anticipate move
	assert_eq(
		model.psyche_anticipated_index,
		target_index,
		"Model should anticipate movement"
	)

	# Simulate returning from scenario
	map.advance_position()
	await get_tree().process_frame

	assert_eq(
		model.current_index,
		target_index,
		"Model should update current index"
	)

	# Psyche view position should match layout position
	var expected_pos := model.layout.node_positions[target_index]
	assert_eq(
		view.psyche_view.position,
		expected_pos,
		"Psyche view should move to target node"
	)

	assert_true(
		map.visible,
		"Map should be visible after advancing position"
	)
	

# make sure map doesnt auto-advance when clicking reward card
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
	
