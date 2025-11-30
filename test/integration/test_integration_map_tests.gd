extends GutTest

var map

func before_each():
	var scene: PackedScene = load("res://Model/Scenes/Map/map.tscn")
	map = scene.instantiate()
	add_child(map)

	await get_tree().process_frame


func after_each():
	map.queue_free()


func test_move_to_new_scenario():
	var scenario1: Node2D = _get_scenario_by_index(1)
	assert_not_null(
		scenario1,
		"Scenario at index 1 should exist at game start"
	)

	scenario1.emit_signal("interacted", scenario1)
	await get_tree().process_frame   # allow map to hide

	map.advance_position()
	await get_tree().process_frame   # allow position + conversions

	var psyche: Node2D = map.psyche_node

	assert_eq(
		psyche.get_meta("index"),
		1,
		"Psyche should now be at index 1"
	)

	assert_eq(
		psyche.position,
		scenario1.position,
		"Psyche should move to the clicked scenario's location"
	)

	assert_true(
		map.visible,
		"Map should be visible again after moving"
	)

	var neighbors: Array = map.get_connected_nodes(1)

	for idx in neighbors:
		if idx in [0, 1, 2]:
			continue

		var s: Node2D = _get_scenario_by_index(idx)
		assert_not_null(
			s,
			"Neighbor %s should be converted from unknown → scenario" % idx
		)

func _get_scenario_by_index(i: int) -> Node2D:
	for s in map.scenarios:
		if s.get_meta("index") == i:
			return s
	return null
