extends Area2D

@export var power_penalty_on_respawn: float = 20.0

func _on_body_entered(body):
	if body.name == "Ball":
		var main_player = GameManager.getPlayer()
		if main_player:
			main_player.setPower(-power_penalty_on_respawn)
		body.reset_ball()
