extends Node

@export var player: Player
@export var scenario: Scenario
@export var card_manager: CardManager
@export var map: Map

#UI root node
var UI: Control

#boolean to see if the player has lost
var playerLost: bool = false

#references to UI elements
var hullIntegrityLabel: Label
var powerLabel: Label
var veloctiyLabel: Label
var rewardsHolder: HBoxContainer

var scenarioHeader: Label
var scenarioEffectLabel: Label

var hullIntegrityBar : TextureProgressBar
var powerBar : TextureProgressBar
var velocityBar : TextureProgressBar

#reference to AnimationPlayers
#UI animation Player
var UIAnimationPlayer : AnimationPlayer

#reference to hand controller
var handController : HandController
#array to hold the rewards from beeating the scenario
var rewards

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
	scenarioHeader.text = scenario.scenarioText
	scenarioEffectLabel.text = scenario.getAffectedAttributes()
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
		get_tree().change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
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
		get_tree().change_scene_to_file("res://Model/ScreenData/LoseScreen.tscn")
		return
	#have the player do what they need to do on the beginning of their turn
	player.beginPlayerTurn()
	#reenable the response label
	UIAnimationPlayer.play("EnableResponse")
	
func endScenario() -> void:
	print("Scenario Won!!!!")
	
	# Get reward scenes
	rewards = card_manager.getReward()
	
	# enable rewardholder and rewardlabel visibility
	rewardsHolder.visible = true
	var rl = UI.get_node("RewardControl/Reward Label")
	var rewardLabelParent = rl.get_parent()
	rewardLabelParent.visible = true
	
	for reward in rewards:
		var rewardInstance: Control = reward.instantiate()
		#save the packed scene for later use
		rewardInstance.set_meta("source_scene", reward)
		#shrink the background of the card for some reason
		rewardInstance.get_child(0).scale.x = 0.49
		rewardInstance.get_child(0).scale.y = 0.5
		rewardInstance.custom_minimum_size = Vector2(250, 0)
		rewardInstance.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		rewardInstance.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		rewardInstance.enableRewardsClickable()
		#connect to the reward chosen signal of the card
		rewardInstance.connect("rewardChosen", Callable(self, "rewardChosen"))
		
		# Add directly to the HBoxContainer
		rewardsHolder.add_child(rewardInstance)
	
	#play end of scenario animation
	UIAnimationPlayer.play("ScenarioEnd")

func rewardChosen(card) -> void:
	#retrive the packed scene
	var packedScene = card.get_meta("source_scene")
	if packedScene:
		#add scene to player's deck 
		player.deck.append(packedScene)
		UIAnimationPlayer.play("ScenarioOutro")
		#remove the chosen cards from the rewards
		rewards.erase(packedScene)
		#append the remaining cards back into the bank
		card_manager.bank += rewards
		card_manager.bank.shuffle()
		
		#reset the player deck
		player.returnAllCards()
		print(player.deck)
		
		#disable rewardholder and reward label visibility
		rewardsHolder.visible = false
		var rl = UI.get_node("RewardControl/Reward Label")
		var rewardLabelParent = rl.get_parent()
		rewardLabelParent.visible = false
		
		#load the map screen 
		map.advance_position()
		if UIAnimationPlayer.is_playing():
			UIAnimationPlayer.stop()
		UIAnimationPlayer.play("HideUI")
		UIAnimationPlayer.play("RESET")
		UI.visible = false
	else:
		print("No packed scene detected, cannot add to player deck")
	return 
