extends Control
class_name Enemy

signal clicked(enemy : Enemy)



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
	mouse_filter = Control.MOUSE_FILTER_STOP
	setChildrenIgnoreMouse(self)
	

func damageEnemy(amt : int) -> void:
	health -= amt
	
	#change healthBar
	healthBar.value = health
	
	#check for death
	if health <= 0:
		emit_signal("enemyDefeated", self)
	
func isDefeated() -> bool:
	return health <= 0 
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Enemy Clicked")
		emit_signal("clicked",self)

func setChildrenIgnoreMouse(node: Node) -> void:
	for c in node.get_children():
		if c is Control:
			(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		setChildrenIgnoreMouse(c)
