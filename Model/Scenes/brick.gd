extends StaticBody2D

signal brick_destroyed

func destroy():
	emit_signal("brick_destroyed")
	queue_free()
