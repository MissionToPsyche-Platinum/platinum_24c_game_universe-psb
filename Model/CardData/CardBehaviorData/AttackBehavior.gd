extends ICardBehavior
class_name AttackBehavior

#number of targets and damage
@export var targets: int
@export var damage: int

func isCardPlayable() -> bool:
	var scenario := GameManager.getScenario()
	if scenario.scenarioType != 1: #battle scenario
		return false
		
	#in case there are no enemies left in a battle scenario
	var battleScenario := scenario as BattleScenario
	for enemy in battleScenario.enemyList:
		if is_instance_valid(enemy):
			if not enemy.isDefeated():
				return true
	return false
	
	
func use() -> bool:
	#get the current scenario
	var battle = GameManager.getScenario() as BattleScenario
	
	#connect to the scenario's signals (once per scenario)
	if not TargetController.enemyClicked.is_connected(onEnemyClicked):
		TargetController.enemyClicked.connect(onEnemyClicked)
		
	#Begin the targeting
	TargetController.beginTargeting(battle, targets)
	
	#await the completion of the targeting
	await TargetController.targetingCompleted
	
	#disconnect from the scenario
	if TargetController.enemyClicked.is_connected(onEnemyClicked):
		TargetController.enemyClicked.disconnect(onEnemyClicked)
		
	return true
	
func onEnemyClicked(enemy : Enemy) -> void:
	#apply damage on click 
	if is_instance_valid(enemy) and not enemy.isDefeated():
		enemy.damageEnemy(damage)
	
	
		
