extends Control
class_name Enemy

#variable to determine the maximum health of an enemy
@export var MAX_HEALTH : int
#reference to the enemy's health bar
@export var healthBar : TextureProgressBar

#health variable
var health


signal enemyDefeated(enemy: Enemy)


func _ready() -> void:
	health = MAX_HEALTH
	healthBar.max_value = MAX_HEALTH
	healthBar.min_value = 0
	healthBar.value = MAX_HEALTH
	

func damageEnemy(amt : int) -> void:
	health -= amt
	
	#change healthBar
	healthBar.value = health
	
	#check for death
	if health <= 0:
		emit_signal("enemyDefeated", self)
	
func isDefeated() -> bool:
	return health <= 0 
	
	


func _on_button_pressed() -> void:
	#damage enemy for testing:
	damageEnemy(1)
