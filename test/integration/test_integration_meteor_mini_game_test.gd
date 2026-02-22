extends GutTest

var scene
var instance
var spawner

func before_each():
	scene = load("res://Model/ScenarioData/Scenarios/MeteorMinigame.tscn")
	instance = scene.instantiate()
	add_child(instance)

	spawner = instance.get_node("ObstacleSpawner")

func after_each():
	instance.queue_free()

func test_obstacle_is_spawned():
	await wait_seconds(1.1)

	var obstacles = spawner.get_children().filter(
		func(child): return child.is_in_group("obstacles")
	)

	assert_gt(obstacles.size(),0,"Expected at least one obstacle to be spawned.")
