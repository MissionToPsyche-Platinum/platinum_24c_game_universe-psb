extends Node

@export var player: Player
@export var scenario: Scenario
@export var card_manager: CardManager

@export var hand: Control

func getPlayer() -> Player:
	return player

func getScenario() -> Scenario:
	return scenario

func getCardManager() -> CardManager:
	return card_manager
	
#not a huge fan of this, might change
func endPlayerTurn() -> void:
	#disable hand 
	hand.visible = false
	await scenario.performScenarioEffect()
	endScenarioTurn()
	
func endScenarioTurn() -> void:
	#reenable hand 
	print("scenario turn ended")
	hand.visible = true
	player.beginPlayerTurn()
	
func loseGame():
	print("Game lost")
	hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
