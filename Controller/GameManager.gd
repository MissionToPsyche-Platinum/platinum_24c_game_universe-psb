extends Node

@export var player: Player
@export var scenario: Scenario
@export var card_manager: CardManager

#references to UI elements
var hullIntegrityLabel: Label
var powerLabel: Label
var veloctiyLabel: Label

var descriptionLabel: Label
var effectLabel: Label

@export var hand: Control

func getPlayer() -> Player:
	return player

func getScenario() -> Scenario:
	return scenario

func getCardManager() -> CardManager:
	return card_manager
	
func loadScenario(scenePath: String) -> void:
	#first unload the current scenario if necessary
	if scenario:
		scenario.queue_free()
		
	#get the scene from the file path
	var scenarioScene = load(scenePath)
	scenario = scenarioScene.instantiate()
	
	#add scenario to scene tree
	add_child(scenario)
	
	#get the scenario description text
	descriptionLabel.text = scenario.scenarioText
	effectLabel.text = scenario.getAffectedAttributes()
	
	
	#connect to scenario signals
	scenario.connect("endScenarioTurn", Callable(self, "endScenarioTurn"))
	scenario.connect("endScenario", Callable(self, "endScenario"))
	
	
	
	print("Scenario is done loading.")
	
	
#not a huge fan of this, might change
func endPlayerTurn() -> void:
	#disable hand 
	hand.visible = false
	await scenario.performScenarioEffect()
	endScenarioTurn()
	
func endScenarioTurn() -> void:
	#reenable hand 
	if !is_instance_valid(hand):
		return
	print("scenario turn ended")
	hand.visible = true
	player.beginPlayerTurn()
	
func endScenario() -> void:
	print("Scenario Won!!!!")
	return 

func loseGame():
	print("Game lost")
	hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
