extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_width := 1000
@export var spawn_y := -50
@export var spawn_delay := 0.5

func _ready():
	# Start the spawn loop as a coroutine
	call_deferred("spawn_loop")

func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_delay).timeout
		spawn_obstacle()

func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = Vector2(randf_range(0, spawn_width), spawn_y)
	add_child(obstacle)
	obstacle.add_to_group("obstacles")
