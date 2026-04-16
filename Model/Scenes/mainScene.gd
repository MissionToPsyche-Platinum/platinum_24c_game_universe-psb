extends Node2D

@export var player: Player
@export var scenario: Scenario
@export var cardManager: CardManager
@export var map: MapController
@export var stats: StatsController

@export var hand: Control 

#assign referenes to UI elements
@export var hullIntegrityLabel: Label
@export var powerLabel: Label
@export var velocityLabel: Label
@export var rewardsHolder: HBoxContainer
@export var rewardEffectHolder: Label

@export var scenarioHeader: Label
@export var scenarioEffectLabel: Label
@export var scenarioWinConditionLabel: Label

@export var hullIntegrityBar : TextureProgressBar
@export var powerBar : TextureProgressBar
@export var velocityBar : TextureProgressBar

#animation player reference
@export var animationPlayer :AnimationPlayer

#hand ui reference
@export var handController : HandController

#draw card preview reference
@export var drawCardPreview : DrawCardPreview



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
	GameManager.scenarioWinConditionsLabel = scenarioWinConditionLabel
	GameManager.hullIntegrityBar = hullIntegrityBar
	GameManager.powerBar = powerBar
	GameManager.velocityBar = velocityBar
	GameManager.rewardsHolder = rewardsHolder
	GameManager.rewardEffectHolder = rewardEffectHolder
	
	#assign animation player references
	GameManager.UIAnimationPlayer = animationPlayer
	
	#assign Hand Controller reference 
	GameManager.handController = handController
	
	#assign draw card preview reference
	GameManager.drawCardPreview = drawCardPreview
	
	# Assign stats reference
	var statsScene = preload("res://Model/Scenes/StatsScene.tscn").instantiate()
	#add_child(statsScene)
	get_tree().root.add_child(statsScene)
	GameManager.stats = statsScene

	#load the scenario
	#GameManager.loadScenario("res://Model/ScenarioData/Scenarios/Sc_DoubleDarkMatter.tscn")
	#load the map
	var mapScene = preload("res://Model/Scenes/Map/map.tscn").instantiate()
	add_child(mapScene)
	GameManager.map = mapScene
	
	#hide scenario UI
	GameManager.UI = $UI
	GameManager.UI.visible = false
	GameManager.UIAnimationPlayer.play("HideUI")
	
	# Hide settings menu
	$SettingsMenu.visible = false


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


func _on_button_pressed() -> void:
	GameManager.restartGame()
	
func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	#visible = false #Remove All Items from Background
	$PauseMenu.visible = get_tree().paused
	# whenever we toggle pause, default back to showing the pause menu
	if has_node("SettingsMenu"):
		$SettingsMenu.visible = false

func _on_Resume_pressed():
	get_tree().paused = false
	#visible = true
	$PauseMenu.visible = false
	if has_node("SettingsMenu"):
		$SettingsMenu.visible = false

func _on_Settings_pressed() -> void:
	if has_node("SettingsMenu"):
		$PauseMenu.visible = false
		$SettingsMenu.visible = true

func _on_SettingsBackButton_pressed() -> void:
	if has_node("SettingsMenu"):
		$SettingsMenu.visible = false
		$PauseMenu.visible = true
