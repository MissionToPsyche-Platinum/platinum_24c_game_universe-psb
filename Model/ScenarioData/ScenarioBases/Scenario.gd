@abstract
extends Node
class_name Scenario


#defines what types of scenarios can exist
enum ScenarioType  {EVENT, BATTLE, MINIGAME}

#the type of the scenario
@export var scenarioType : ScenarioType

#how the scenario will affect the attributes every turn
@export var affectedAttributes : Array[AttributeEffect]

#defines the win condition for the scenario (which attributes need to be how high or low)
@export var attributeWinConditions: Array[AttributeEffect]

#the text that will appear at the top of the screen while in the scenario
@export var scenarioText : String 

#signal to signifiy the end of the scenario turn
signal endScenarioTurn

#signal to signify that the scenario was won
signal scenarioWon

@abstract()
func performScenarioEffect() -> void

#helper function to be run before every scenario to determine if the player has won 
func checkWinCondition() -> bool:
	#for now, each attribute needs to be higher or equal to the win condition
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
					
					

func getAffectedAttributes() -> String:
	var affectedAttributesText: String = ""
	 
	for effect in affectedAttributes:
		match effect.affectedAttribute:
			#Hull Integrity 
			0:
				affectedAttributesText += ("Affecting Hull Integrity by " + str(effect.amount) + "\n")
			#Power
			1:
				affectedAttributesText += ("Affecting Power by " + str(effect.amount) + "\n")
			#Velocity
			2:
				affectedAttributesText += ("Affecting Velocity by " + str(effect.amount) + "\n")
	
	return affectedAttributesText

	
