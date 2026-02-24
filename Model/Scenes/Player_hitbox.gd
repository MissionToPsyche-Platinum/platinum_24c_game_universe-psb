extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Ufo"):
		get_tree().reload_current_scene()

	elif body.is_in_group("EnemyProjectile"):
		body.queue_free()
		var Player = get_parent()
		Player.hit += 1

		if Player.hit >= 3:
			Player.queue_free()
			get_tree().change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
