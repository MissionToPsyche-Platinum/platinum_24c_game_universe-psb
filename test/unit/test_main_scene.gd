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
	assert_not_null(card_container, "CardContainer should exist inside UI/Hand Container")
