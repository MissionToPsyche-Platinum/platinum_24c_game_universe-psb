extends Area2D

@export var speed := 200

func _process(delta):
	position.y += speed * delta
	
	if position.y > 700:
		queue_free()
		
func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()
