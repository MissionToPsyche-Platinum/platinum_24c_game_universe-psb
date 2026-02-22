extends Node


signal enemyClicked(enemy : Enemy)
signal targetingCompleted()


var targetingActive := false
var remainingTargets := 0
var currentScenario: BattleScenario

func beginTargeting(battle: BattleScenario, targets: int) -> void:
	targetingActive = true
	currentScenario = battle
	remainingTargets = targets
	
	#connect to each enemy's clicked signal
	for enemy in currentScenario.enemyList:
		if is_instance_valid(enemy):
			if not enemy.clicked.is_connected(onEnemyClicked):
				enemy.clicked.connect(onEnemyClicked)
				

	#enable the enemies to be clicked
	for e in currentScenario.enemyList:
		if is_instance_valid(e):
			e.mouse_filter = Control.MOUSE_FILTER_STOP

	print("Entering Targeting mode!")
	##UI changes
	#Tween out the scenario text 
	var tween = create_tween()
	tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,0), 0.25)
	await tween.finished
	
	GameManager.scenarioHeader.text = "Select Targets \nTargets remaning: " + str(remainingTargets)
	
	tween = create_tween()
	tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,1), 0.25)
	
func onEnemyClicked(enemy: Enemy) -> void:
	if not targetingActive:
		return
	if enemy.isDefeated():
		return 
		

	emit_signal("enemyClicked", enemy)
	
	remainingTargets -= 1
	
	#change ui
	GameManager.scenarioHeader.text = "Select Targets \nTargets remaning: " + str(remainingTargets)
	
	
	if remainingTargets <= 0:
		endTargeting()
		
	if checkEarlyScenarioEnd():
		endTargeting()
			
func endTargeting() -> void:
	if not targetingActive:
		return 
		
	targetingActive = false
	
	#disconnect from the signals 
	if currentScenario:
		for enemy in currentScenario.enemyList:
			if is_instance_valid(enemy) and enemy.clicked.is_connected(onEnemyClicked):
				enemy.clicked.disconnect(onEnemyClicked) 
	
	
	#set the mouse filters
	for e in currentScenario.enemyList:
		if is_instance_valid(e):
			e.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
	#emit the finished targeting signal
	emit_signal("targetingCompleted")
	
	
func checkEarlyScenarioEnd() -> bool:
	#helper function for checking if the scenario needs to end before all the targets are used
	for enemy in currentScenario.enemyList:
		if is_instance_valid(enemy):
			if not enemy.isDefeated():
				return false
	return true
