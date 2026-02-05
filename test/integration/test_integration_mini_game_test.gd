extends GutTest

var scene
var instance
var movable_object

func before_each():
	scene = load("res://Model/ScenarioData/ScenarioBases/MinigameScenarion.tscn")
	instance = scene.instantiate()
	add_child(instance)

	# Adjust path to your movable object
	movable_object = instance.get_node("Player") 

func after_each():
	instance.queue_free()

func test_object_moves_when_velocity_applied():
	var start_pos = movable_object.global_position

	movable_object.velocity = Vector2(200, 0)

	# Run multiple physics frames
	await wait_physics_frames(5)

	var end_pos = movable_object.global_position

	assert_gt(
		end_pos.x,
		start_pos.x,
		"Object should move to the right"
	)
	
func test_destroy_asteroid():
	
