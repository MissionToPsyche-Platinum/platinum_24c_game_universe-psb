extends Area2D

@export var hull_penalty_on_hit: float = 20.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Ufo"):
		get_tree().reload_current_scene()

	elif body.is_in_group("EnemyProjectile"):
		body.queue_free()
		var main_player = GameManager.getPlayer()
		if main_player:
			main_player.setHullIntegrity(-hull_penalty_on_hit)
		var Player = get_parent()
		Player.hit += 1
