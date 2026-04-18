extends CharacterBody2D

@export var speed := 300
@export var projectile_scene: PackedScene

# Movement boundaries
@export var min_x := 484
@export var max_x := 1060
var hit := 0

func _ready():
	var sprite: Sprite2D = null
	var named := get_node_or_null("Sprite2D")
	if named is Sprite2D:
		sprite = named
	if sprite == null:
		for child in get_children():
			if child is Sprite2D:
				sprite = child
				break
	if sprite and sprite.texture:
		var sprite_height = sprite.texture.get_height() * sprite.scale.y
		$Muzzle.position = Vector2(0, -sprite_height / 2 - 2)
	else:
		$Muzzle.position = Vector2(0, -10)
	add_to_group("Player")  # Make the player detectable by obstacles


func _physics_process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"):  direction.x -= 1

	velocity = direction.normalized() * speed
	move_and_slide()  
	
	position.x = clamp(position.x, min_x, max_x)

	if Input.is_action_just_pressed("ui_accept"):
		shoot()

func _get_projectile_container() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	var c: Node = tree.current_scene
	if c == null and is_inside_tree():
		c = get_parent()
	if c == null:
		c = tree.root
	return c

func shoot():
	if projectile_scene == null:
		print("Error: projectile_scene is not assigned!")
		return
	var projectile = projectile_scene.instantiate()
	var container := _get_projectile_container()
	if container == null:
		projectile.queue_free()
		return
	container.add_child(projectile)
	projectile.global_position = $Muzzle.global_position
	projectile.direction = Vector2.UP
	projectile.add_to_group("Projectile")
