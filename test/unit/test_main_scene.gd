extends GutTest

var main_scene: PackedScene
var main_node: Node2D

func before_all():
	main_scene = load("res://Model/Scenes/MainScene.tscn")

func before_each():
	main_node = main_scene.instantiate()
	get_tree().root.add_child(main_node)  # attach to running scene tree
	get_tree().current_scene = main_node  # ensures get_tree() works in TitleScreen.gd

func after_each():
	main_node.queue_free()

func test_card_container():
	var card_container =  main_node.get_node_or_null("UI/Hand Container/Card Container")
	assert_not_null(card_container, "CardContainer should exist inside the UI")

func test_left_arrow():
	var Left_Arrow = main_node.get_node_or_null("UI/Hand Container/Left Arrow/Left Arrow Button")
	assert_not_null(Left_Arrow, "Left Arrow button should exist inside the UI")

func test_right_arrow():
	var Right_Arrow = main_node.get_node_or_null("UI/Hand Container/Right Arrow/Right Arrow Button")
	assert_not_null(Right_Arrow, "Right Arrow button should exist inside the UI")

func test_reward_holder():
	var Reward_Holder = main_node.get_node_or_null("UI/Reward Holder")
	assert_not_null(Reward_Holder, "Reward Holder should exist inside the UI")
	
