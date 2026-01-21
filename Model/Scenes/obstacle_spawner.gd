extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_width := 500
@export var spawn_y := -50
#@export var spawn_delay := 1.0

#func _ready():
#	spawn_loop()

#func spawn_loop():
#	while true:
#		await get_tree().create_timer(spawn_delay).timeout
#		spawn_obstacle()

#func spawn_obstacle():
#	var obstacle = obstacle_scene.instantiate()
#	obstacle.position = Vector2(
#		randf_range(100, spawn_width),
#		spawn_y
#	)
#	add_child(obstacle)
