extends Node2D

@export var player: Player
@export var scenario: Scenario
@export var cardManager: CardManager
@export var map: Map

@export var hand: Control 

#assign referenes to UI elements
@export var hullIntegrityLabel: Label
@export var powerLabel: Label
@export var velocityLabel: Label
@export var rewardsHolder: HBoxContainer

@export var scenarioHeader: Label
@export var scenarioEffectLabel: Label

@export var hullIntegrityBar : TextureProgressBar
@export var powerBar : TextureProgressBar
@export var velocityBar : TextureProgressBar

#animation player reference
@export var animationPlayer :AnimationPlayer

#hand ui reference
@export var handController : HandController






# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#reset player lost flag
	GameManager.playerLost = false
	
	
	#register all values with the GameManager
	GameManager.player = player
	GameManager.card_manager = cardManager
	GameManager.hand = hand
	
	
	#assign UI references
	GameManager.hullIntegrityLabel = hullIntegrityLabel
	GameManager.powerLabel = powerLabel
	GameManager.veloctiyLabel = velocityLabel
	GameManager.scenarioHeader = scenarioHeader
	GameManager.scenarioEffectLabel = scenarioEffectLabel
	GameManager.hullIntegrityBar = hullIntegrityBar
	GameManager.powerBar = powerBar
	GameManager.velocityBar = velocityBar
	GameManager.rewardsHolder = rewardsHolder
	
	#assign animation player references
	GameManager.UIAnimationPlayer = animationPlayer
	
	print("assigning hand controller...")
	print(handController)
	#assign Hand Controller reference 
	GameManager.handController = handController
	
	
	
	#load the scenario
	#GameManager.loadScenario("res://Model/ScenarioData/Scenarios/Sc_DoubleDarkMatter.tscn")
	var mapScene = preload("res://Model/Scenes/Map/Map.tscn").instantiate()
	add_child(mapScene)
	GameManager.map = mapScene
	GameManager.UI = $UI
	$UI.visible = false


func _on_response_label_gui_input(event: InputEvent) -> void:
	#display card gui
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				animationPlayer.play("DisplayCardGui")


func _on_scenario_label_gui_input(event: InputEvent) -> void:
	#stop displaying card gui
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				animationPlayer.play("HideCardGui")
