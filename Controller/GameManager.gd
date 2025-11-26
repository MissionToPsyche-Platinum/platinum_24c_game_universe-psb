extends Node

@export var player: Player
@export var scenario: Scenario
@export var card_manager: CardManager

#boolean to see if the player has lost
var playerLost: bool = false

#references to UI elements
var hullIntegrityLabel: Label
var powerLabel: Label
var veloctiyLabel: Label

var descriptionLabel: Label
var effectLabel: Label

var hullIntegrityBar : TextureProgressBar
var powerBar : TextureProgressBar
var velocityBar : TextureProgressBar

#reference to AnimationPlayers
#UI animation Player
var UIAnimationPlayer : AnimationPlayer

#reference to hand controller
var handController : HandController

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
	scenario.connect("endScenario", Callable(self, "endScenario"))
	scenario.connect("endScenarioTurn", Callable(self, "endScenarioTurn"))
	
	
	
	#Scenario is done loading
	print("Scenario is done loading.")
	
	#have the player draw a new hand
	player.getNewHand()
	
	#play the intro animation
	UIAnimationPlayer.play("PsycheScenarioStart")
	
	
#not a huge fan of this, might change
func endPlayerTurn() -> void:
	#check if the player lost on their turn
	if playerLost:
		get_tree().change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
		return
	
	scenario.performScenarioEffect()
	
func endScenarioTurn() -> void:
	print("scenario turn ended") 
	#check if the player lost on scenario turn
	if playerLost:
		get_tree().change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
		return
	#have the player do what they need to do on the beginning of their turn
	player.beginPlayerTurn()
	#reenable the response label
	UIAnimationPlayer.play("EnableResponse")
	
func endScenario() -> void:
	print("Scenario Won!!!!")
	return 

func loseGame():
	print("Game lost")
	playerLost = true
	
