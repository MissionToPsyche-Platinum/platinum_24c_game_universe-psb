extends Scenario
class_name EventScenario


func performScenarioEffect() -> void:
	
	if(checkWinCondition()):
		#win condition has been met, emit signal and return from function 
		print("Scenario has been defeated!")
		emit_signal("scenarioWon")
		return 
	
	for effect in affectedAttributes:
		match effect.affectedAttribute:
			#hull Integrity
			0:
				print("Damaging Hull Integritry by " + str(effect.amount))
				GameManager.getPlayer().setHullIntegrity(effect.amount)
			#power
			1:
				print("Damaging Power by " + str(effect.amount))
				GameManager.getPlayer().setPower(effect.amount)
			#velocity
			2: 
				print("Damaging Velocity by " + str(effect.amount))
				GameManager.getPlayer().setVelocity(effect.amount)
	
	await get_tree().create_timer(1).timeout
	
	print("Emmitting endScenarioTurn signal...")
	emit_signal("endScenarioTurn")
	#emit the end scenario turn signal 
	
	
