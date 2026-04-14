extends GutTest

const SCENE = preload("res://Model/ScenarioData/Scenarios/MG_ShootingMinigame.tscn")

var instance
var signal_emitted := false

func before_each():
	instance = SCENE.instantiate()
	add_child(instance)

func after_each():
	instance.queue_free()

func test_wins_when_enemy_destroyed():
	await wait_frames(2)

	var ufo = instance.get_tree().get_first_node_in_group("UFO")
	assert_not_null(ufo, "UFO should have spawned.")

	# ✅ Disable AI to prevent infinite coroutine crash
	ufo.disable_ai = true
	ufo.set_process(false)
	ufo.set_physics_process(false)

	instance.scenarioWon.connect(_on_scenario_won)

	ufo.eliminated()

	await wait_frames(1)

	assert_true(signal_emitted, "scenarioWon should be emitted.")

func _on_scenario_won():
	signal_emitted = true
