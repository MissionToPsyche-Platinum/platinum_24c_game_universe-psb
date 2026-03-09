extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_width := 412
@export var spawn_y := -50
@export var spawn_delay := 0.9

var stopped := false
@onready var minigame = get_parent()

func _ready():
	call_deferred("spawn_loop")

func spawn_loop() -> void:
	while not stopped:
		await get_tree().create_timer(spawn_delay).timeout
		if stopped:
			break
		spawn_obstacle()

func stop_spawning():
	stopped = true

func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = Vector2(randf_range(450, 450+spawn_width), spawn_y)
	add_child(obstacle)
	obstacle.add_to_group("obstacles")
	
	# Connect the meteor's collision signal to minigame
	obstacle.player_hit.connect(_on_player_hit)

func _on_player_hit():
	print("Player hit! Game Over!")
	stop_spawning()
	minigame.player.queue_free()
