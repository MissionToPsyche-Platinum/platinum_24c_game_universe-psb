extends GutTest

## Acceptance: the Destroyer ball reflects off the paddle (CharacterBody2D), matching in-game behavior.

const BALL_SCENE := preload("res://Model/Scenes/Ball.tscn")

var _world: Node2D


func before_each() -> void:
	_world = Node2D.new()
	add_child(_world)


func after_each() -> void:
	if is_instance_valid(_world):
		_world.queue_free()
	_world = null


func test_ball_bounces_off_paddle_character_body() -> void:
	var paddle := CharacterBody2D.new()
	var paddle_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(59, 38)
	paddle_shape.shape = rect
	paddle.add_child(paddle_shape)
	paddle.position = Vector2(400, 420)
	_world.add_child(paddle)

	var ball: CharacterBody2D = BALL_SCENE.instantiate()
	ball.position = Vector2(400, 360)
	_world.add_child(ball)

	ball.direction = Vector2(0, 1).normalized()
	ball.is_active = true

	var downward_before: float = ball.direction.y
	assert_gt(downward_before, 0.0, "Precondition: ball should start moving toward the paddle (down).")

	await wait_physics_frames(60,
		"Allow enough physics steps for the ball to reach the paddle and bounce.")

	assert_lt(ball.direction.y, 0.0,
		"Acceptance: after hitting the paddle, the ball should head upward (bounce off the player).")
