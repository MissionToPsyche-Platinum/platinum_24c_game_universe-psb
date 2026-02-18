extends Node2D

@export var ufo_scene: PackedScene
@export var spawn_width := 412
@export var spawn_y := 170
@export var spawn_delay := 0.5

func _ready():
	# Start the spawn loop as a coroutine
	call_deferred("spawn_ufo")

#func spawn_loop() -> void:
#	while true:
#		await get_tree().create_timer(spawn_delay).timeout
#		spawn_ufo()

func spawn_ufo():
	var UFO = ufo_scene.instantiate()
	UFO.position = Vector2(randf_range(450, 450+spawn_width), spawn_y)
	add_child(UFO)
	UFO.add_to_group("ufo")
