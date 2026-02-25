extends GutTest

var main_scene: PackedScene
var main_node: Node2D

func before_all():
	# Load the MainScene once for all tests
	main_scene = load("res://Model/Scenes/MainScene.tscn")

func before_each():
	# Instantiate the scene before each test
	main_node = main_scene.instantiate()
	get_tree().root.add_child(main_node)  # attach to running scene tree
	get_tree().current_scene = main_node  # ensures get_tree() works in TitleScreen.gd

func after_each():
	# Clean up after each test
	main_node.queue_free()

func test_card_container():
	var card_container = main_node.get_node_or_null("UI/Hand Container/Card Container")
	assert_not_null(card_container, "CardContainer should exist inside the UI")

func test_reward_label() -> void:
	# Wait until "Reward Label" exists (in case it’s added dynamically)
	while not main_node.has_node("UI/Reward Label"):
		await get_tree().process_frame
	
	var reward_label = main_node.get_node("UI/Reward Label")
	assert_not_null(reward_label, "Reward Label should exist inside the UI")
