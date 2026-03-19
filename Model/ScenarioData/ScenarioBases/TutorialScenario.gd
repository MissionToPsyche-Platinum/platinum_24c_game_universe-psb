class_name TutorialScenario
extends Scenario

@export var earthAnimationPlayer: AnimationPlayer
@export var UIAnimationPlayer: AnimationPlayer
@export var ResponseLabelAnimationPlayer : AnimationPlayer
@export var scenarioHeaderLabel: Label
@export var clickAnywhereLabel : Label
@export var hullIntegrityBar : TextureProgressBar
@export var velocityBar : TextureProgressBar
@export var powerBar : TextureProgressBar
@export var hullIntegrityLabel : Label
@export var velocityLabel : Label
@export var powerLabel : Label
@export var trashCanIcon : Sprite2D
@export var trashCanButton : Button

@export var advanceTutorialClickable: Control 

@export var handController : HandController
@export var cardManager : CardManager

@export var scenarioEffectLabel : Label
@export var scenarioWinConditionLabel : Label

@export var freebieCard : PackedScene
@export var discardCard : PackedScene
@export var battleCard : PackedScene

@export var protocolCard : Control

@export var enemyPosition : Control
@export var enemyScene : PackedScene

@export var selectResponseLabel : Control

var tutorialEventScenario : EventScenario
var tutorialBattleScenario : BattleScenario
var tutorialPlayer : Player


	

var tutorialSteps = []
var currentIndex:= 0

func _ready() -> void:
	
	# initalize tutorial objects
	tutorialPlayer = Player.new()
	#set gamemanager objects
	
	GameManager.tutorialMode = true
	GameManager.tutorialScenario = self
	GameManager.hullIntegrityBar = hullIntegrityBar
	GameManager.velocityBar = velocityBar
	GameManager.powerBar = powerBar
	GameManager.scenarioEffectLabel = scenarioEffectLabel
	GameManager.scenarioWinConditionsLabel = scenarioWinConditionLabel
	GameManager.UIAnimationPlayer = UIAnimationPlayer
	GameManager.hullIntegrityLabel = hullIntegrityLabel
	GameManager.veloctiyLabel = velocityLabel
	GameManager.powerLabel = powerLabel
	GameManager.scenarioHeader = scenarioHeaderLabel
	
	
	
	GameManager.player =  tutorialPlayer
	GameManager.card_manager = cardManager
	GameManager.handController = handController
	
	GameManager.player.deck.append(freebieCard)
	GameManager.player.drawCard(false)
	
	
	
	
	tutorialSteps= [
		{
			"text": "Welcome to Psyche Against the Universe!",
			"actions": [enableClickable]
		},
		{
			"text": "In this game, you play as the Psyche Spacecraft!",
			"actions": [enableClickable, youArrow]
		},
		{
			"text": "Your purpose: to journey to...",
			"actions" : [youArrowDown, enableClickable]
			
		},
		{
			"text": "The Psyche Asteriod!",
			"actions": [enableClickable, psycheAsteroidShow]
		},
		{
			"text": "This asteroid, located in our own asteroid belt, is believed to be the core of a protoplanet - a very rare find!",
			"actions": [enableClickable]
			
		},
		{
			"text" : "By studying it, NASA can figure out more about how planets are created - even how Earth was created!",
			"actions": [enableClickable]
		},
		{
			"text": "Imagine the scientific discoveries we could make by going to the Psyche Asteroid!",
			"actions" : [enableClickable]
		},
		{
			"text" : "No, really, imagine. We don't know what we'll find there. That's why we're sending you!",
			"actions" : [enableClickable, psycheAsteroidHide]
		},
		{
			"text" : "Of course, studying it is the easy part. Getting there is much harder.",
			"actions" : [enableClickable]
		},
		{
			"text" : "Each game starts in orbit around earth, which, unfortunately, is not the Psyche Asteroid.",
			"actions" : [enableClickable, mapBooShow]
		},
		{
			"text" : "Your objective is to reach the Psyche Asteroid.",
			"actions": [enableClickable, mapYayShow]
		},
		{
			"text" : "That's quite the treck, but don't you worry - Mission Control has identified a map with several different paths for you to take!",
			"actions" : [enableClickable, mapPathShow]
		},
		{
			"text" : "Each map has several different nodes, but Psyche's scanners can only identify the nodes closest to it - which are highlighted orange.",
			"actions" : [enableClickable, mapNodesShow]
		},
		{
			"text" : "Those are the ones you'll be able to choose to progress on the map, which is just as easy as clicking them!",	
			"actions" : [enableClickable]
		},
		{
			"text" : "But be careful - those nodes aren't just pockets of empty space, but rather Scenarios that Psyche will have to overcome to progress!",
			"actions" : [enableClickable, mapNodesHide]
		},
		{
			"text" : "Space ain't just all sunshine and rainbows, my friend. (In fact, there aren't any rainbows at all.)",
			"actions" : [enableClickable]
		},
		{
			"text" : "Each Scenario will attempt to destroy the Psyche Spacecraft before it gets to the Psyche Asteroid!",
			"actions" : [enableClickable]
		},
		{
			"text" : "It'll do this by targeting one of the Psyche Spacecraft's attributes: HEALTH, POWER, or VELOCITY.",
			"actions" : [enableClickable, showAttributes]
		},
		{
			"text" : "If any one of Psyche's attributes gets reduced to 0 at any point, you'll lose the game.",
			"actions" : [enableClickable]
		},
		{
			"text" : "But don't worry, you'll be able to overcome these Scenarios with the power of...",
			"actions" : [enableClickable]
		},
		{
			"text" : "Protocol Cards!",
			"actions" : [enableClickable, showProtocolCard]
		},
		{
			"text" : "Protocol Cards are all unique, and strategic use of them will help you overcome whatever Scenario you're in!",
			"actions" : [enableClickable]
		},
		{
			"text" : "You'll start the game with a set amount of them, and you'll earn more every time you beat a Scenario.",
			"actions" : [enableClickable]
		},
		{
			"text" : "Why don't we give an Event Scenario a try to get a feel for beating Scenarios?",
			"actions" : [enableClickable, hideProtocolCard]
		},
		{
			"text" : "Out of the three Scenario types, Events are the simplest.",
			"actions" : [enableClickable]
		},
		{
			"text" : "After you play a card, an Event Scenario will simply directly reduce one of your attributes by a set amount.",
			"actions" : [enableClickable, setScenarioEffectLabelEventText, showScenarioEffectLabel]
		},
		{
			"text" : "Event Scenarios also have a win condition, where you have to have an equal or above amount of a certain Attribute to beat the Scenario. In this case, you need 130 Velocity or above.",
			"actions" : [enableClickable, setScenarioWinConditionLabelEventText, showScenarioWinConditionLabel ]	
		},
		{
			"text" : "Clicking the Response label will let you see all of the cards currently in your hand.",
			"actions" : [enableClickable, scenarioResponseShow]	
		},
		{
			"text" : "You can look through your hand by clicking the left or right arrows.",
			"actions" : [enableClickable, scenarioArrowShow]
		},
		{
			"text" : "The card in the middle of the card screen will tell you what it does in the bottom left under EFFECTS.",
			"actions" : [enableClickable, scenarioEffectsShow]	
		},
		{
			"text" : "To use a card, click the left or right arrows on the card screen until the card you want to use is in the middle, then click Select Response. It's that easy!",
			"actions" : [enableClickable, scenarioSelectResponseShow]
		},
		{
			"text" : "Try it out with the card I just gave you!",
			"actions" : [enableResponse, scenarioSelectResponseHide]
		},
		{
			"text" : "Nice work!",
			"actions" : [enableClickable, performTutorialEventScenarioEffect]
		},
		{
			"text" : "Notice how your Velocity was increased by the amount specified in the card, and your Hull Integrity decreased by the amount specified in the Scenario Effects!",
			"actions" : [enableClickable]
		},
		{
			"text" : "I'm sure you get it by now - use your cards to beat the Scenario before it beats you!",
			"actions" : [enableClickable]
		},
		{
			"text" : "To make sure you're equipped enough, you'll draw a card from your deck on the beginning of your turn if possible.",	
			"actions" : [enableClickable]
		},
		{
			"text" : "However, not all cards can be used in Event Scenarios. That's where Discarding comes into play!",
			"actions" : [enableClickable]
		},
		{
			"text" : "On your turn, you'll be able to select multiple cards to throw away from your hand, and in return, you'll draw the same amount of cards you that you discarded on your next turn! (Assuming you have enough in your deck.)",
			"actions" : [enableClickable]
		},
		{
			"text" : "To discard cards, simply click the trash can icon while the card you want to discard is in the middle of the card screen.",
			"actions" : [enableClickable, discardStart]
		},
		{
			"text" : "This will cause the trashcan to turn red, toggling the card for discarding, and the discard button to appear.",
			"actions" : [enableClickable, discardButton]
		},
		{
			"text" : "You can then use the arrows to choose more cards to discard if you want.",
			"actions" : [enableClickable, discardArrows]
		},
		{
			"text" : "If you change your mind about discarding a card, simply click the trashcan again. This will untoggle it from discarding.",
			"actions" : [enableClickable, discardTrashCan]
		},
		{
			"text" : "Once your choice has been made, simply click the discard button and you're done!",
			"actions" : [enableClickable, discardFinalShow]
		},
		{
			"text" : "Discarding will cost you your turn, so be careful when choosing to use it.",
			"actions" : [enableClickable, discardFinalHide]
		},
		{
			"text" : "I've given you an Attack Card, which can't be used in event scenarios. Try discarding it!",
			"actions" : [enableResponse, giveDiscardCard, hideSelectResponseLabel]
		},
		{
			"text" : "Perfect! In an actual Scenario, you would have drawn an extra card on your turn.",
			"actions" : [enableClickable, performTutorialEventScenarioEffect, showSelectResponseLabel]
		},
		{
			"text" : "Alright, that's enough foofing around here. Let's beat this scenario!",
			"actions" : [enableClickable]
		},
		{
			"text" : "I've given you another Freebie Card. Go ahead and use it to beat the scenario!",
			"actions" : [enableResponse, giveFreebie]
		},
		{
			"text" : "Nice work!",
			"actions" : [hideScenarioEffectLabels,enableClickable]
			
		},
		{
			"text" : "In a real scenario, you'll be able to select a reward card to add to your deck to be used for future Scenarios. Keep on the lookout for rarer cards!",
			"actions" : [enableClickable]
		},
		{
			"text" : "That should do it for the...",
			"actions" : [enableClickable]
		},
		{
			"text" : "...Hold on, what is that?",
			"actions" : [prepareBattleScenario, showCardbot]
		
		},
		{
			"text" : "OH NO! IT'S CARDBOT! HE'S COME TO DESTROY YOU!",
			"actions" : [enableClickable]
		},
		{
			"text" : "You'll have to play a Battle Scenario to beat him!",
			"actions" : [enableClickable]
		},
		{
			"text" :  "Battle Scenarios are a lot like Event Scenarios- they will also try to reduce one of your attributes.",
			"actions" : [enableClickable, setScenarioEffectLabelBattleText, showScenarioEffectLabel]
		},
		{
			"text" : "But in this case, how much it's reduced will be a base value multiplied by how many enemies are left in the Battle Scenario!",
			"actions" : [enableClickable]
		},
		{
			"text" : "In this case, there's only one enemy, so your Hull Integrity will be reduced by 10 * 1 = 10 points each turn.",
			"actions" : [enableClickable]
		},
		{
			"text" : "Battle Scenarios also have a win condition: You must defeat all of the enemies to beat the Scenario.",
			"actions" : [enableClickable, setScenarioWinConditionLabelBattleText, showScenarioWinConditionLabel]
		},
		{
			"text" : "In order to defeat them, you have to use Battle Cards!",
			"actions" : [enableClickable]
		},
		{
			"text" : "Instead of increasing your attributes, Battle Cards have a number of Damage and Targets.",
			"actions" : [enableClickable, battleCardEffects]
		},
		{
			"text" : "The Damage shows how much it will reduce the chosen enemy's HP by, and the number of Targets shows how many times you can damage enemies after using it.",
			"actions" : [enableClickable, battleTargetDamage]
		},
		{
			"text" : "Once a Battle Card is used, you'll enter Targeting Mode, and the number of targets you have left will be displayed a the top of the screen.",
			"actions" : [enableClickable, battleTargetingMode]
		},
		{
			"text" : "Simply hover over the enemy you wish to damage and click on them to use one of your targets!",
			"actions" : [enableClickable, battleClickShow]
		},
		{
			"text" : "You'll leave Targeting Mode once you use all of your targets, or all enemies have been defeated.",
			"actions" : [enableClickable]
		},
		{
			"text" : "I've just given you a Battle Card. Try damaging Cardbot!",
			"actions" : [giveBattleFreebie, enableResponse, battleClickHide]
		},
		{
			"text" : "Nice Job!",
			"actions" : [enableClickable]
		},
		{
			"text" : "Notice how your Hull Integrity was affected, just like the last scenario.",
			"actions" : [enableClickable]
		},
		{
			"text" : "Alright, we know the drill by now. I've given you another freebie, go ahead and finish this scenario!",
			"actions" : [giveBattleFreebie, enableResponse]
		},
		{
			"text" : "The evil has been defeated. Amazing Job!",
			"actions" : [enableClickable, hideScenarioEffectLabels, hideAttributes]
		},
		{
			"text" : "That about does it for the technical part of the tutorial.",
			"actions" : [enableClickable]
		},
		{
			"text" : "The third type of Scenario, the Minigame Scenario, has you take a break from the Card formula and play a quick minigame!",
			"actions" : [enableClickable]
		},
		{
			"text" : "We think you'll have more fun discovering those on your own.",
			"actions" : [enableClickable]
		},
		{
			"text" : "You're as ready as you'll ever be for your journey - it's time you start heading towards the Psyche Asteroid!",
			"actions" : [enableClickable]
		},
		{
			"text" : "Good luck out there!",
			"actions" : [enableClickable]
		},
		{
			"text" : "And remember...",
			"actions" : [enableClickable],
			
		},
		{
			"text" : "It's Psyche Against the Universe!",
			"actions" : [enableClickable]
		},
		{
			"actions" : [scenarioOutro]
		}
		
		
		
	]

	play_tutorial()

func play_tutorial() -> void:
	earthAnimationPlayer.play("earthSpin")
	UIAnimationPlayer.play("TutorialBegin")

func progressTutorial() -> void:
	
	#finish the current animation
	var currentAnimation = UIAnimationPlayer.current_animation
	if currentAnimation != "":
		await UIAnimationPlayer.animation_finished
	
	
	#check if an action needs to be performed  
	if tutorialSteps[currentIndex].has("actions") and tutorialSteps[currentIndex]["actions"] != null:
		for action in tutorialSteps[currentIndex]["actions"]:
			action.call()
		
	
	if tutorialSteps[currentIndex].has("text") and tutorialSteps[currentIndex]["text"] != null:
		#display the text of the current index
		changeHeaderText(tutorialSteps[currentIndex]["text"])
	
	#increment tutorialIndex
	currentIndex += 1
	
	


func changeHeaderText(text: String) -> void:
	var tween = create_tween()
	tween.tween_property(scenarioHeaderLabel, "modulate:a", 0.0, 0.25)
	await tween.finished

	scenarioHeaderLabel.text = text

	tween = create_tween()
	tween.tween_property(scenarioHeaderLabel, "modulate:a", 1.0, 0.25)
	await tween.finished


func enableClickable() -> void:
	#inable the clickable
	advanceTutorialClickable.visible = true
	
	#await 1 second timeout
	await get_tree().create_timer(1.0).timeout
	
	#enable click anywhere to continue label
	clickAnywhereLabel.visible = true
	
	#tween the alpha to fade in
	var tween = create_tween()
	tween.tween_property(clickAnywhereLabel, "modulate:a", 1, 1)
	
func _on_gui_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "TutorialBegin":
		progressTutorial()
	elif anim_name == "ShowCardbot":
		progressTutorial()
	elif anim_name == "ScenarioOutro":
		get_tree().change_scene_to_file("res://Model/ScreenData/TitleScreen.tscn")
		GameManager.restartGame()
		
		
		
func performScenarioEffect() -> void:
	pass
	
func getWinCondition() -> String:
	return ""


func _on_advance_tutorial_clickable_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#disable the clickable
		advanceTutorialClickable.visible = false
		
		#disable the click anywhere label
		clickAnywhereLabel.visible = false
		
		#set the label's alpha to 0 for fade in
		clickAnywhereLabel.modulate.a = 0
		
		#progress the tutorial 
		progressTutorial()



#ANIMATION FUNCTIONS
func youArrow() -> void:
	UIAnimationPlayer.play("YOUArrow")
	
func youArrowDown() -> void:
	UIAnimationPlayer.play("YOUArrowDown")
	
func psycheAsteroidShow() -> void:
	UIAnimationPlayer.play("PsycheAsteroidShow")
	
func psycheAsteroidHide() -> void:
	UIAnimationPlayer.play("PsycheAsteroidHide")
	
func mapBooShow() -> void:
	UIAnimationPlayer.play("MapBooShow")

func mapYayShow() -> void:
	UIAnimationPlayer.play("MapYayShow")

func mapPathShow() -> void:
	UIAnimationPlayer.play("MapPathShow")

func mapNodesShow() -> void:
	UIAnimationPlayer.play("MapNodesShow")
	
func mapNodesHide() -> void:
	UIAnimationPlayer.play("MapNodesHide")

func showAttributes() -> void:
	UIAnimationPlayer.play("ShowAttributes")

func showProtocolCard() -> void:
	UIAnimationPlayer.play("ShowProtocolCard")

func hideProtocolCard() -> void:
	#it took me this long to find this function
	UIAnimationPlayer.play_backwards("ShowProtocolCard")
	await UIAnimationPlayer.animation_finished
	protocolCard.visible = false
	
func showScenarioEffectLabel() -> void:
	UIAnimationPlayer.play("ShowScenarioEffectLabel")
	
func setScenarioEffectLabelEventText() -> void:
	scenarioEffectLabel.text = "Affecting Hull Integrity by 10.0"
	
func setScenarioEffectLabelBattleText() -> void:
	scenarioEffectLabel.text = "Affecting Hull Integrity by 10.0 * 1 (Currently Active Enemies)"

func showScenarioWinConditionLabel() -> void:
	UIAnimationPlayer.play("ShowScenarioWinConditionLabel")
	
func setScenarioWinConditionLabelEventText() -> void:
	scenarioWinConditionLabel.text = "Scenario Win Condition:\n130 Velocity"
	
func setScenarioWinConditionLabelBattleText() -> void:
	scenarioWinConditionLabel.text = "Scenario Win Condition:\nDefeat All Enemies"
	
func enableResponse() -> void:
	ResponseLabelAnimationPlayer.play(&"RESET")
	ResponseLabelAnimationPlayer.play("EnableResponse")

func performTutorialEventScenarioEffect() -> void:
	GameManager.player.setHullIntegrity(-10)

func giveDiscardCard() -> void:
	GameManager.player.deck.append(discardCard)
	GameManager.player.drawCard(false)
	trashCanButton.visible = true
	trashCanIcon.visible = true
	
func giveFreebie() -> void:
	GameManager.player.deck.append(freebieCard)
	GameManager.player.drawCard(false)
	trashCanButton.visible = false
	trashCanIcon.visible = false

func hideScenarioEffectLabels() -> void:
	UIAnimationPlayer.play("HideScenarioLabels")
	
func giveBattleFreebie() -> void:
	GameManager.player.deck.append(battleCard)
	GameManager.player.drawCard(false)
	trashCanButton.visible = false
	trashCanIcon.visible = false
	
	
func showCardbot() -> void:
	UIAnimationPlayer.play("ShowCardbot")

func prepareBattleScenario() -> void:
	#create a battle scenario
	var battleScenario = BattleScenario.new()
	battleScenario.scenarioType = 1
	battleScenario.enemyPositions.append(enemyPosition)
	battleScenario.enemyScenes.append(enemyScene)
	GameManager.scenario = battleScenario
	GameManager.scenario.initializeBattleScenario()
	
func scenarioResponseShow() -> void:
	UIAnimationPlayer.play("ScenarioResponseShow")
	
func scenarioArrowShow() -> void:
	UIAnimationPlayer.play("ScenarioArrowShow")

func scenarioEffectsShow() -> void:
	UIAnimationPlayer.play("ScenarioEffectsShow")
	
func scenarioSelectResponseShow() -> void:
	UIAnimationPlayer.play("ScenarioSelectResponseShow")
	
func scenarioSelectResponseHide() -> void:
	UIAnimationPlayer.play("ScenarioSelectResponseHide")

func discardStart() -> void:
	UIAnimationPlayer.play("DiscardStart")
	
func discardButton() -> void:
	UIAnimationPlayer.play("DiscardButton")

func discardArrows() -> void:
	UIAnimationPlayer.play("DiscardArrows")
	
func discardTrashCan() -> void:
	UIAnimationPlayer.play("DiscardTrashCan")

func discardFinalShow() -> void:
	UIAnimationPlayer.play("DiscardFinalShow")

func discardFinalHide() -> void:
	UIAnimationPlayer.play("DiscardFinalHide")

func hideAttributes() -> void:
	UIAnimationPlayer.play_backwards("ShowAttribues")

func showSelectResponseLabel() -> void:
	selectResponseLabel.visible = true

func hideSelectResponseLabel() -> void:
	selectResponseLabel.visible = false
	
func battleCardEffects() -> void:
	UIAnimationPlayer.play("BattleCardEffects")
	
func battleTargetDamage() -> void:
	UIAnimationPlayer.play("BattleTargetDamage")
	
func battleTargetingMode() -> void:
	UIAnimationPlayer.play("BattleTargetingMode")
	
func battleClickShow() -> void:
	UIAnimationPlayer.play("BattleClickShow")
	
func battleClickHide() -> void:
	UIAnimationPlayer.play("BattleClickHide")

func scenarioOutro() -> void:
	UIAnimationPlayer.play("ScenarioOutro")	


func performBattleScenarioEffect() -> void:
	GameManager.player.setHullIntegrity(-10)

# signal functions
func _on_response_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		UIAnimationPlayer.play("DisplayCardGui")


func _on_scenario_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		UIAnimationPlayer.play("HideCardGui")
		
	
