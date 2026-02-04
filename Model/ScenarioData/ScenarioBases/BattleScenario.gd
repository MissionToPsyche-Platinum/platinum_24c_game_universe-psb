extends Scenario
class_name BattleScenario

#holder for the enemy grid
@export var enemyContainer : Control

#enemy grid
@export var enemyGrid : GridContainer

#enemy holder AnimationPlayer
@export var enemyContainerAnimationPlayer : AnimationPlayer

#list of scenes used to instantiate enemies
@export var enemyScenes : Array[PackedScene]

#List of enemies that will be in the scenario
var enemyList : Array[Enemy]


func _ready() -> void:
	#clear old enemies
	for child in enemyGrid.get_children():
		child.queue_free()
	enemyList.clear()
				
	#instantiate all enemies
	var instances : Array[Enemy] 
	for enemyScene in enemyScenes:
		var enemy = enemyScene.instantiate()
		#godot moment
		if enemy is Enemy:
			instances.append(enemy)
		else:
			push_error("Tried to append non-enemy into enemy list in BattleScenario, dont do that idiot")
		
	#shuffle the placement of the enemies 
	instances.shuffle()
	
	#add the enemies to the grid and enemyList
	for enemy in instances:
		enemyGrid.add_child(enemy)
		#connect to enemy defeated signal
		enemy.connect("enemyDefeated", Callable(self, "enemyDefeated"))
		enemyList.append(enemy)
		
	#slide the enemies onto the screen
	enemyContainerAnimationPlayer.play("ShowGrid")
			

func performScenarioEffect() -> void:
	
	if(checkWinCondition()):
		#win condition has been met, emit signal and return from function 
		print("Scenario has been defeated!")
		emit_signal("scenarioWon")
		return 
	
	#get the enemy multiplier
	var mult = getAliveEnemyCount()
	
	for attribute in affectedAttributes:
		match attribute.affectedAttribute:
			#hull Integrity
			0:
				GameManager.getPlayer().setHullIntegrity(attribute.amount * mult)
			#power
			1:
				GameManager.getPlayer().setPower(attribute.amount * mult)
			#velocity
			2: 
				GameManager.getPlayer().setVelocity(attribute.amount * mult)
				
	#emit the end turn signal 
	emit_signal("endScenarioTurn")

				
func checkWinCondition() -> bool:
	#check if all enemies are defeated 
	for enemy in enemyList:
		if !(enemy.isDefeated()):
			return false
			
	#check for attribute win conditions
	for condition in attributeWinConditions:
		match condition.affectedAttribute:
			#hull integrity
			0:
				if !(GameManager.getPlayer().hullIntegrity >= condition.amount):
					#condition is not met, continue scenario
					return false
			1:
				if !(GameManager.getPlayer().power >= condition.amount):
					#condition is not met, continue scenario
					return false
			2:
				if !(GameManager.getPlayer().velocity >= condition.amount):
					#condition is not met, continue scenario
					return false
	
	
	#if all conditions are passed, return true
	return true
					
					
func getWinCondition() -> String:
	var header = ""
	var conditions = ""
	
	#in battle scenarios, there will always be enemies, and attribute conditions are optional
	if affectedAttributes.size() > 0:
		header = "Scenario Win Conditions:\n"
	else:
		header = "Scenario Win Condition:"
		
	#the scenario will always have enemies
	conditions = "Defeat All Enemies\n"
	
	#append the possible attribute conditions
	conditions += getAffectedAttributes()
	
	return header + conditions
	
	
func getAliveEnemyCount() -> int:
	var count = 0
	
	for enemy in enemyList:
		if !(enemy.isDefeated()):
			count += 1
	return count
	
	
func enemyDefeated(enemy : Enemy) -> void:
	#remove the enemy from the grid
	enemyGrid.remove_child(enemy)
	#
			
