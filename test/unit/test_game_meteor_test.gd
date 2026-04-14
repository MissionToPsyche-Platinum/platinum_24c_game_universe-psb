extends GutTest

var obstacle

func before_each():
	obstacle = preload("res://Model/Scenes/Obstacle.tscn").instantiate()
	add_child_autofree(obstacle)

func test_emits_player_hit():
	watch_signals(obstacle)

	var fake_player = CharacterBody2D.new()
	fake_player.name = "Player"

	obstacle._on_body_entered(fake_player)

	assert_signal_emitted(obstacle, "player_hit")
