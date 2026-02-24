extends GutTest

var ufo

func before_each():
	# Instantiate the UFO directly (assumes you added class_name UFO in your script)
	var UFOScene = preload("res://Model/Scenes/ufo.gd")
	ufo = UFOScene.new()
	add_child_autofree(ufo) 

func test_ufo_destroyed_emits_signal_and_frees():
	watch_signals(ufo)

	ufo.eliminated()

	assert_signal_emitted(ufo, "destroyed")

	assert_true(ufo.is_queued_for_deletion())
