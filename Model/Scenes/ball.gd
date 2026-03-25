extends CharacterBody2D

@export var speed: float = 300.0
var direction: Vector2
var start_position: Vector2
var is_active: bool = false

func _ready():
	randomize()
	start_position = global_position
	direction = Vector2(1, -1).normalized()

func _physics_process(delta):

	if !is_active:
		if Input.is_action_just_pressed("ui_accept"):
			launch_ball()
		return

	var collision = move_and_collide(direction * speed * delta)
	
	if collision:
		var collider = collision.get_collider()

		direction = direction.bounce(collision.get_normal())
		
		if collider.has_method("destroy"):
			collider.destroy()

func launch_ball():
	var random_x = randf_range(-0.8, 0.8)
	direction = Vector2(random_x, -1).normalized()
	is_active = true

func reset_ball():
	global_position = start_position
	direction = Vector2(1, -1).normalized()
	is_active = false
