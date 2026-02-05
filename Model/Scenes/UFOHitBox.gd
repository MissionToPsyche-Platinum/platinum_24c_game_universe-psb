extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().reload_current_scene()

	elif body.is_in_group("Projectile"):
		body.queue_free()
		var enemy = get_parent()
		enemy.hit += 1

		if enemy.hit >= 3:
			enemy.queue_free()
