extends Scenario
class_name EventScenario

@export var eventScenarioIntroMusic : AudioStreamPlayer
@export var eventScenarioLoopoMusic : AudioStreamPlayer


func _ready():
	#play the music 
	#eventScenarioIntroMusic.play()
	pass

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
	
func getWinCondition() -> String:
		var header = ""
		var conditions = ""
		
		if attributeWinConditions.size() > 1:
			header = "Scenario Win Conditions: \n "
		else:
			header = "Scenario Win Condition: \n "
			
		for condition in attributeWinConditions:
			match condition.affectedAttribute:
				0: 
					conditions += (str(condition.amount) + " Hull Integrity\n")
				1:
					conditions += (str(condition.amount) + " Power\n")
				2:
					conditions += (str(condition.amount) + " Velocity\n")
		
		return header + conditions
				
					

func _on_event_scenario_intro_music_finished() -> void:
	eventScenarioLoopoMusic.play()
