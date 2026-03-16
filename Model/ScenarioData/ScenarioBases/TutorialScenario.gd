extends Scenario

@export var earthAnimationPlayer: AnimationPlayer
@export var UIAnimationPlayer: AnimationPlayer
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
	GameManager.scenario = self
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
			"actions" : [enableClickable, showScenarioEffectLabel]
		},
		{
			"text" : "Event Scenarios also have a win condition, where you have to have an equal or above amount of a certain Attribute to beat the Scenario. In this case, you need 130 Velocity or above.",
			"actions" : [enableClickable, showScenarioWinConditionLabel]	
		},
		{
			"text" : "Clicking the Response label will let you see all of the cards currently in your hand. You can look through your hand by clicking the left or right arrows.",
			"actions" : [enableClickable]	
		},
		{
			"text" : "The card in the middle of the card screen will tell you what it does in the bottom left under EFFECTS.",
			"actions" : [enableClickable]	
		},
		{
			"text" : "To use a card, click the left or right arrows on the card screen until the card you want to use is in the middle, then click Select Response. It's that easy!",
			"actions" : [enableClickable]
		},
		{
			"text" : "Try it out with the card I just gave you!",
			"actions" : [enableResponse]
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
			"actions" : [enableClickable]
		},
		{
			"text" : "This will cause the trashacan to turn red, toggling the card for discarding, and the discard button to appear.",
			"actions" : [enableClickable]
		},
		{
			"text" : "You can then use the arrows to choose more cards to discard if you want.",
			"actions" : [enableClickable]
		},
		{
			"text" : "If you change your mind about discarding a card, simply click the trashcan again. This will untoggle it from discarding.",
			"actions" : [enableClickable]
		},
		{
			"text" : "Once your choice has been made, simply click the discard button and you're done!",
			"actions" : [enableClickable]
		},
		{
			"text" : "Discarding will cost you your turn, so be careful when choosing to use it.",
			"actions" : [enableClickable]
		},
		{
			"text" : "I've given you an Attack Card, which can't be used in event scenarios. Try discarding it!",
			"actions" : [enableResponse, giveDiscardCard]
		},
		{
			"text" : "Perfect! In an actual Scenario, you would have drawn an extra card on your turn.",
			"actions" : [enableClickable, performTutorialEventScenarioEffect]
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
		var animationData = UIAnimationPlayer.get_animation(currentAnimation)
		if animationData != null:
			UIAnimationPlayer.seek(animationData.length, true)
	
	
	#check if an action needs to be performed  
	if tutorialSteps[currentIndex].has("actions") and tutorialSteps[currentIndex]["actions"] != null:
		for action in tutorialSteps[currentIndex]["actions"]:
			action.call()
		
	
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

	UIAnimationPlayer.duplicate().play("YOUArrow")
	
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
	
func showScenarioEffectLabel() -> void:
	scenarioEffectLabel.text = "Affecting Hull Integrity by 10.0"
	UIAnimationPlayer.play("ShowScenarioEffectLabel")

func showScenarioWinConditionLabel() -> void:
	scenarioWinConditionLabel.text = "Scenario Win Condition:\n130 Velocity"
	UIAnimationPlayer.play("ShowScenarioWinConditionLabel")
	
func enableResponse() -> void:
	UIAnimationPlayer.play("EnableResponse")

func performTutorialEventScenarioEffect() -> void:
	GameManager.player.setHullIntegrity(-10)

func giveDiscardCard() -> void:
	GameManager.player.deck.append(discardCard)
	GameManager.player.drawCard(false)
	trashCanButton.visible = true
	trashCanIcon.visible = true
	
	


# signal functions
func _on_response_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		UIAnimationPlayer.play("DisplayCardGui")


func _on_scenario_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		UIAnimationPlayer.play("HideCardGui")
		
	
