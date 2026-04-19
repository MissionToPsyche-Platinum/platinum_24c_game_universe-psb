extends GutTest

## System test: full game path can be completed by progressing through map scenarios
## from start toward the end node, which should transition to WinScreen.

const MAP_SCENE := preload("res://Model/Scenes/Map/map.tscn")
const MAP_LAYOUT := preload("res://Model/MapData/Maps/Map_8Nodes.tres")
const WIN_SCREEN_PATH := "res://Model/ScreenData/WinScreen.tscn"

var _map: MapController
var _stats: StatsController
var _player: Player


func before_each() -> void:
	_map = MAP_SCENE.instantiate()
	_map.layout = MAP_LAYOUT
	get_tree().root.add_child(_map)
	get_tree().current_scene = _map

	_stats = StatsController.new()
	get_tree().root.add_child(_stats)

	_player = Player.new()
	get_tree().root.add_child(_player)

	GameManager.stats = _stats
	GameManager.player = _player
	GameManager.map = _map

	await get_tree().process_frame


func after_each() -> void:
	var current_scene := get_tree().current_scene

	if is_instance_valid(_player):
		_player.queue_free()
	if is_instance_valid(_stats):
		_stats.queue_free()
	if is_instance_valid(_map):
		_map.queue_free()
	if is_instance_valid(current_scene) and current_scene.scene_file_path == WIN_SCREEN_PATH:
		current_scene.queue_free()

	GameManager.player = null
	GameManager.stats = null
	GameManager.map = null

	await get_tree().process_frame


func test_full_game_can_be_completed_via_map_scenario_progression() -> void:
	var model := _map.model
	assert_not_null(model, "Map should initialize a model in _ready.")
	assert_false(model.has_won, "Game should not start in a won state.")

	var path_to_finish := _path_to_pre_end_node(_map.layout)
	assert_gt(path_to_finish.size(), 0, "Map layout should contain a route from start toward end.")

	for next_index in path_to_finish:
		_map.map_active = true
		var previous_index := model.current_index

		_map._on_node_clicked(next_index)
		assert_eq(model.psyche_anticipated_index, next_index,
			"Clicking active neighbor should set anticipated move.")

		_map.advance_position()
		await wait_process_frames(2)

		assert_eq(model.current_index, next_index,
			"Completing a scenario should advance Psyche along the route.")
		assert_ne(model.current_index, previous_index,
			"Current map index should change after scenario completion.")

	assert_true(model.has_won,
		"Reaching the node before the end should mark the map as won.")

	var went_to_win_screen: bool = await wait_until(
		func() -> bool:
			return (
				get_tree().current_scene != null
				and get_tree().current_scene.scene_file_path == WIN_SCREEN_PATH
			),
		5.0,
		0.05,
		"Completing map progression should transition to WinScreen."
	)
	assert_true(went_to_win_screen, "Timed out waiting for transition to WinScreen.")


func _path_to_pre_end_node(layout: MapLayout) -> Array[int]:
	var target_nodes := {}
	for predecessor in _get_preceding_neighbors(layout.end_index, layout.connections):
		target_nodes[predecessor] = true

	var queue: Array[int] = [layout.start_index]
	var parents := {layout.start_index: -1}
	var found_target := -1

	while queue.size() > 0 and found_target == -1:
		var current := queue.pop_front()
		if target_nodes.has(current):
			found_target = current
			break

		for next in _get_proceeding_neighbors(current, layout.connections):
			if parents.has(next):
				continue
			parents[next] = current
			queue.append(next)

	if found_target == -1:
		return []

	var reverse_path: Array[int] = []
	var cursor := found_target
	while cursor != layout.start_index:
		reverse_path.append(cursor)
		cursor = parents[cursor]

	reverse_path.reverse()
	return reverse_path


func _get_proceeding_neighbors(index: int, connections: Array[Vector2i]) -> Array[int]:
	var neighbors: Array[int] = []
	for edge in connections:
		if edge.x == index:
			neighbors.append(edge.y)
	return neighbors


func _get_preceding_neighbors(index: int, connections: Array[Vector2i]) -> Array[int]:
	var neighbors: Array[int] = []
	for edge in connections:
		if edge.y == index:
			neighbors.append(edge.x)
	return neighbors
