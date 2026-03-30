extends Enemy
class_name DarkPsycheEnemy

@export var enemy_texture: Texture2D

func _ready() -> void:
	# If set, override the base EnemySprite texture (EnemyBase.tscn defaults to aliens.png).
	if enemy_texture and sprite:
		sprite.texture = enemy_texture
	super._ready()
