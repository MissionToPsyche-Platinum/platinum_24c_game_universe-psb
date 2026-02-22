extends Node


@export var player: Player
@export var scenario: Scenario
@export var card_manager: CardManager
@export var map: Map

#UI root node
var UI: Control

#boolean to see if the player has been instantiated 
var playerInstantiated: bool = false

#boolean to see if the player has lost
var playerLost: bool = false


#references to UI elements
var hullIntegrityLabel: Label
var powerLabel: Label
var veloctiyLabel: Label
var rewardsHolder: HBoxContainer

var scenarioHeader: Label
var scenarioEffectLabel: Label
var scenarioWinConditionsLabel : Label

var hullIntegrityBar : TextureProgressBar
var powerBar : TextureProgressBar
var velocityBar : TextureProgressBar

#UI animation Player
var UIAnimationPlayer

#reference to hand controller
var handController : HandController

var drawCardPreview : DrawCardPreview

#array to hold the rewards from beeating the scenario
var rewards

@export var hand: Control

#instantiation function so the player hand gets created when the game reloads
func _ready() -> void:
	playerInstantiated = false

func getPlayer() -> Player:
	return player

func getScenario() -> Scenario:
	return scenario

func getCardManager() -> CardManager:
	return card_manager

func change_scene_to_file(path: String) -> void:
	get_tree().change_scene_to_file(path)
	
func loadScenario(scenePath: String) -> void:
	#first unload the current scenario if necessary
	if scenario:
		scenario.queue_free()
		
	#ensure the player has been instantiated properly
	if !playerInstantiated:
		player.instantiatePlayerDeck()
		playerInstantiated = true
	
	#get the scene from the file path
	var scenarioScene = load(scenePath)
	scenario = scenarioScene.instantiate()
	
	#add scenario to scene tree
	add_child(scenario)
	
	#get the scenario description text
	scenarioHeader.text = scenario.scenarioText
	scenarioEffectLabel.text = scenario.getAffectedAttributes()   
	scenarioWinConditionsLabel.text = scenario.getWinCondition()
	print(scenarioHeader.text)

	#connect to scenario signals
	scenario.connect("scenarioWon", Callable(self, "endScenario"))
	scenario.connect("endScenarioTurn", Callable(self, "endScenarioTurn"))
	
	#Scenario is done loading
	print("Scenario is done loading.")
	# enable scenario UI
	UIAnimationPlayer.play("ShowUI")
	UI.visible = true
	
	#have the player draw a new hand
	player.getNewHand()
	
	#play the intro animation
	UIAnimationPlayer.play("PsycheScenarioStart")
	

func endPlayerTurn() -> void:
	print("Ending player turn")
	#check if the player lost on their turn
	if playerLost:
		self.change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
		return
	
	#tween the header text back to the scenario 
	var tween = create_tween()
	tween.tween_property(scenarioHeader, "modulate", Color(1,1,1,0), 0.25)
	await tween.finished
	
	scenarioHeader.text = scenario.scenarioText
	
	tween = create_tween()
	tween.tween_property(scenarioHeader, "modulate", Color(1,1,1,1), 0.25)
	
	
	scenario.performScenarioEffect()
	
func endScenarioTurn() -> void:
	print("scenario turn ended") 
	#check if the player lost on scenario turn
	if playerLost:
		self.change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
		return
	#have the player do what they need to do on the beginning of their turn
	player.beginPlayerTurn()
	#reenable the response label
	UIAnimationPlayer.play("EnableResponse")
	
func endScenario() -> void:
	print("Scenario Won!!!!")
	
	# Get reward scenes
	rewards = card_manager.getReward()
	
	#show the rewards
	rewardsHolder.visible = true
	
	for reward in rewards:
		var rewardInstance: Control = reward.instantiate()
		#save the packed scene for later use
		rewardInstance.set_meta("source_scene", reward)
		
		#set the scale of the reward option
		rewardInstance.scale.x = 0.49
		rewardInstance.scale.y = 0.5
		
		#create a control wrapper with a specified minimun distance
		var wrapper := Control.new()
		wrapper.custom_minimum_size = Vector2(300, 0)
		wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		#add reward instance as child of wrapper
		wrapper.add_child(rewardInstance)
		
			
		rewardInstance.enableRewardsClickable()
		#connect to the reward chosen signal of the card
		rewardInstance.connect("rewardChosen", Callable(self, "rewardChosen"))
		
		#add wrapper to hbox
		rewardsHolder.add_child(wrapper)
	
	#play end of scenario animation
	UIAnimationPlayer.play("ScenarioEnd")

func rewardChosen(card) -> void:
	# Retrieve the packed scene
	var packedScene = card.get_meta("source_scene")
	if packedScene:
		# Add scene to player's deck 
		player.deck.append(packedScene)
		UIAnimationPlayer.play("ScenarioOutro")

		# Remove the chosen card from the rewards
		rewards.erase(packedScene)

		# Append remaining rewards safely back into the card manager bank
		if card_manager:
			if not card_manager.bank:
				card_manager.bank = []
			card_manager.bank.append_array(rewards)
			card_manager.bank.shuffle()

		# Reset the player deck
		player.returnAllCards()
		print(player.deck)
		
		#reset the hand controller
		handController.resetHandController()
		
		#remove all children from the rewards holder
		for child in rewardsHolder.get_children():
			child.queue_free()
		

		# Disable rewardsHolder and reward label visibility
		if rewardsHolder:
			rewardsHolder.visible = false
		var rl = UI.get_node("RewardControl/Reward Label")
		if rl:
			var rewardLabelParent = rl.get_parent()
			if rewardLabelParent:
				rewardLabelParent.visible = false

		# Load the map screen safely
		if map and map.has_method("advance_position"):
			map.advance_position()
		else:
			print("Warning: Map is not assigned or missing 'advance_position' method")

		# Handle UI animations
		if UIAnimationPlayer:
			if UIAnimationPlayer.is_playing():
				UIAnimationPlayer.stop()
			UIAnimationPlayer.play("HideUI")
			UIAnimationPlayer.play("RESET")
		
		if UI:
			UI.visible = false
	else:
		print("No packed scene detected, cannot add to player deck")
		
		
func restartGame() -> void:
	#this function will be called whenever the game needs to restart
	#reset player instantiation
	playerInstantiated = false
	
	#reset player attributes
	player.hullIntegrity = 100
	player.velocity = 100
	player.power = 100
	
	#reset the game scene
	get_tree().change_scene_to_file("res://Model/Scenes/MainScene.tscn")
	
