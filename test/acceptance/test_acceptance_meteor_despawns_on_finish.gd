extends GutTest

## Acceptance: when the Meteor minigame finishes, the minigame ship and spawned meteors
## are removed from play (no stray obstacles or player node left under the minigame root).

const METEOR_SCENE := preload("res://Model/ScenarioData/Scenarios/MG_MeteorMinigame.tscn")

var _meteor_root: Node
var _won: bool = false
var _saved_time_scale: float = 1.0


func before_each() -> void:
	_won = false
	_saved_time_scale = Engine.time_scale


func after_each() -> void:
	Engine.time_scale = _saved_time_scale
	if is_instance_valid(_meteor_root):
		_meteor_root.queue_free()
	_meteor_root = null
	await get_tree().process_frame


func _on_meteor_won() -> void:
	_won = true


func test_player_and_meteors_despawn_when_meteor_minigame_finishes() -> void:
	_meteor_root = METEOR_SCENE.instantiate()
	var meteor: MeteorMinigame = _meteor_root as MeteorMinigame
	assert_not_null(meteor, "MG_MeteorMinigame root should use MeteorMinigame.")

	meteor.survival_time = 2.0
	var spawner: Node2D = meteor.get_node("ObstacleSpawner")
	spawner.spawn_delay = 0.15

	add_child(_meteor_root)
	meteor.scenarioWon.connect(_on_meteor_won)

	Engine.time_scale = 30.0

	var spawned: bool = await wait_until(
		func() -> bool: return get_tree().get_nodes_in_group("obstacles").size() > 0,
		30.0,
		0.02,
		"A meteor obstacle should spawn."
	)
	assert_true(spawned, "Timed out waiting for a meteor to spawn.")

	var finished: bool = await wait_until(
		func() -> bool: return _won,
		30.0,
		0.02,
		"Minigame should finish after survival_time."
	)
	assert_true(finished, "Timed out waiting for scenarioWon.")

	await wait_process_frames(2)

	assert_eq(
		get_tree().get_nodes_in_group("obstacles").size(),
		0,
		"Acceptance: meteors should despawn when the minigame ends."
	)
	assert_null(
		meteor.get_node_or_null("Player"),
		"Acceptance: minigame Player should despawn when the minigame ends."
	)
