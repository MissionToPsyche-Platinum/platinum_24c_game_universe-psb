extends GutTest

var brick

func before_each():
	# Instantiate the brick directly
	var BrickScene = preload("res://Model/Scenes/brick.gd")
	brick = BrickScene.new()
	add_child_autofree(brick)

func test_brick_destroyed_emits_signal_and_frees():
	watch_signals(brick)

	brick.destroy()
	assert_signal_emitted(brick, "brick_destroyed")

	assert_true(brick.is_queued_for_deletion())
