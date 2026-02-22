extends CharacterBody2D

@export var speed := 200
@export var projectile_scene: PackedScene
@export var shoot_interval := 1.5
@export var disable_ai := false
var ufo_direction := 1
var hit := 0
signal destroyed


func _physics_process(delta):
	velocity.x = speed * ufo_direction
	move_and_slide()

	if is_on_wall():
		ufo_direction *= -1

func _ready():
	if disable_ai:
		return
	shoot_loop()

func shoot_loop() -> void:
	while true:
		await get_tree().create_timer(shoot_interval).timeout
		shoot_at_player()

func shoot_at_player():
	if projectile_scene == null:
		return

	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = $Muzzle.global_position

	projectile.direction = (player.global_position - global_position).normalized()

	projectile.add_to_group("EnemyProjectile")
	
func eliminated():
	emit_signal("destroyed")
	queue_free()
