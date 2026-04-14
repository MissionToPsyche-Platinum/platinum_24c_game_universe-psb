extends GutTest

const SCENE = preload("res://Model/ScenarioData/Scenarios/MG_DestroyerMinigame.tscn")

var instance
var signal_emitted := false

func before_each():
	instance = SCENE.instantiate()
	add_child(instance)

func after_each():
	instance.queue_free()

func test_wins_when_all_bricks_destroyed():
	await wait_frames(1)

	var bricks = instance.get_children().filter(
		func(child): return child.has_method("destroy")
	)

	assert_gt(bricks.size(), 0, "Bricks should have been placed.")

	instance.scenarioWon.connect(_on_scenario_won)

	for brick in bricks:
		brick.destroy()

	await wait_frames(1)

	assert_true(signal_emitted, "scenarioWon should be emitted when all bricks are destroyed.")

func _on_scenario_won():
	signal_emitted = true
