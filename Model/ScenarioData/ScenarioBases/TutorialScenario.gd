extends Scenario

@export var earthAnimationPlayer: AnimationPlayer
@export var UIAnimationPlayer: AnimationPlayer
@export var scenarioHeaderLabel: Label

@export var advanceTutorialClickable: Control 


#SIGNALS
signal tutorialBeginAnimationFinished
signal tutorialWelcome
signal tutorialTeach

var tutorialSteps = []
var currentIndex:= 0

func _ready() -> void:
	tutorialSteps= [
		{
			"text": "Welcome to the tutorial!",
			"action": enableClickable
		},
		{
			"text": "Here, you will learn about the game.",
			"action": enableClickable
		},
		{
			"text": "Let's get started!",
			
		}
	]

	play_tutorial()

func play_tutorial() -> void:
	earthAnimationPlayer.play("earthSpin")
	UIAnimationPlayer.play("TutorialBegin")

func progressTutorial() -> void:
	
	#check if an action needs to be performed  
	if tutorialSteps[currentIndex].has("action") and tutorialSteps[currentIndex]["action"] != null:
		tutorialSteps[currentIndex]["action"].call()
		
	
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
	print("enabling clickable...")
	advanceTutorialClickable.visible = true 
	
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
		progressTutorial()
