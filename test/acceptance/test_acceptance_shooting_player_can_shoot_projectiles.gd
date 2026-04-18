extends GutTest

## Acceptance: in the shooting minigame, the player can fire a projectile (Projectile group)
## into the active scene. Uses the same current_scene wiring as real play.

const SHOOTING_SCENE := preload("res://Model/ScenarioData/Scenarios/MG_ShootingMinigame.tscn")

var _shooting_root: Node


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


func after_each() -> void:
	if is_instance_valid(_shooting_root):
		_shooting_root.queue_free()
	_shooting_root = null
	await get_tree().process_frame


func test_player_shoot_spawns_projectile_in_minigame() -> void:
	_shooting_root = SHOOTING_SCENE.instantiate()
	# current_scene must be a direct child of the viewport root (same as change_scene_to_file).
	get_tree().root.add_child(_shooting_root)
	get_tree().current_scene = _shooting_root

	await wait_process_frames(4)
	_forgive_known_scenario_ui_animation_warnings()

	var ufo: Node = get_tree().get_first_node_in_group("UFO")
	assert_not_null(ufo, "Minigame should spawn a UFO.")
	ufo.disable_ai = true
	ufo.set_process(false)
	ufo.set_physics_process(false)

	var player: Node = _shooting_root.get_node("Player")
	assert_not_null(player, "Shooting minigame should include Player.")

	var before: int = get_tree().get_nodes_in_group("Projectile").size()

	# Edge so Input.is_action_just_pressed("ui_accept") is true in _physics_process (same as real play).
	Input.action_release("ui_accept")
	await wait_physics_frames(1)
	Input.action_press("ui_accept")
	await wait_physics_frames(2)
	Input.action_release("ui_accept")

	_forgive_known_scenario_ui_animation_warnings()

	var after: int = get_tree().get_nodes_in_group("Projectile").size()
	assert_gt(
		after,
		before,
		"Acceptance: shooting should add at least one node to group Projectile."
	)
