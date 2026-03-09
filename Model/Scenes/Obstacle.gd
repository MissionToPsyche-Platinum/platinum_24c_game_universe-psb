extends Area2D

@export var speed := 200
signal player_hit

func _physics_process(delta):
	position.y += speed * delta
	if position.y > 700:
		queue_free()

func _ready():
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D:
		player_hit.emit()
		queue_free()  # optional: destroy meteor on hit
