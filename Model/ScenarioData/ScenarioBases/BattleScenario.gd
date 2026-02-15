extends Scenario
class_name BattleScenario

#holder for the enemy grid
@export var enemyContainer : Control

#array of enemy control positions
@export var enemyPositions : Array[Control]

#enemy holder AnimationPlayer
@export var enemyContainerAnimationPlayer : AnimationPlayer

#list of scenes used to instantiate enemies
@export var enemyScenes : Array[PackedScene]

#List of enemies that will be in the scenario
var enemyList : Array[Enemy]


func _ready() -> void:
	#clear old enemies
	for position in enemyPositions:
		if position.get_child(0) != null:
			position.get_child(0).queue_free()
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
	
	# place these enemies on the various position nodes and add them to enemy list, connect to enemy signal 
	for i in range(instances.size()):
		enemyList.append(instances[i])
		enemyPositions[i].add_child(instances[i])
		instances[i].connect("enemyDefeated", Callable(self, "enemyDefeated"))
		
		
	for e in enemyList:
		print(e.name, " size=", e.size, " min=", e.get_combined_minimum_size(), " filter=", e.mouse_filter)
	
	
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
		if is_instance_valid(enemy):
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
	if attributeWinConditions.size() > 0:
		header = "Scenario Win Conditions:\n"
	else:
		header = "Scenario Win Condition:\n"
		
	#the scenario will always have enemies
	conditions = "Defeat All Enemies\n"
	
	#append the possible attribute conditions
	for attribute in attributeWinConditions:
		match attribute.affectedAttribute:
			0: 
				conditions += (str(attribute.amount) + " Hull Integrity\n")
			1:
				conditions += (str(attribute.amount) + " Power\n")
			2:
				conditions += (str(attribute.amount) + " Velocity\n")
	
	return header + conditions
	
	
func getAliveEnemyCount() -> int:
	var count = 0
	
	for enemy in enemyList:
		if is_instance_valid(enemy):
			if !(enemy.isDefeated()):
				count += 1
	return count
	
	
func enemyDefeated(enemy : Enemy) -> void:
	#find the enemy position
	for position in enemyPositions:
		if position.get_child(0) == enemy:
			position.get_child(0).queue_free()
			
	#update the scenario effects label
	GameManager.scenarioEffectLabel.text = getAffectedAttributes()

func getAffectedAttributes() -> String:
	var affectedAttributesString := ""
	for attribute in affectedAttributes:
		match attribute.affectedAttribute:
			0:
				#hull integrity 
				affectedAttributesString += "Affecting Hull Integrity By " + str(attribute.amount) + " * " + str(getAliveEnemyCount()) + " (Currently Active Enemies)"
			1:
				#Power
				affectedAttributesString += "Affecting Power " + str(attribute.amount) + " * " + str(getAliveEnemyCount()) + " (Currently Active Enemies)"
			2:
				#Velocity
				affectedAttributesString += "Affecting Velocity By " + str(attribute.amount) + " * " + str(getAliveEnemyCount()) + " (Currently Active Enemies)"
		affectedAttributesString += "\n"
	
	return affectedAttributesString
