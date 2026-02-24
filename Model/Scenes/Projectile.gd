extends CharacterBody2D

@export var speed := 600
@export var lifetime := 2.0
var direction := Vector2.UP

func _ready():
	remove_after_lifetime()

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("Wall") or collider.is_in_group("Projectile"):  
			queue_free()

# Coroutine-style function
func remove_after_lifetime() -> void:
	await get_tree().create_timer(lifetime).timeout
	if self.is_inside_tree():
		queue_free()
