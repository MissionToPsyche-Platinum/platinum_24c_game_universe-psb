extends Node2D

const _SETTINGS_MUSIC_SLIDER_PATH := NodePath("SettingsMenu/Setting Screen/HSlider")
const _MUSIC_BUS_NAME := "Music"

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

#sound
@onready var openMenuSFX : AudioStreamPlayer = $MenuOpenSFX
@onready var closeMenuSFX : AudioStreamPlayer = $MenuCloseSFX
@onready var winSFX: AudioStreamPlayer = $WinSFX
@export var loseSFX : AudioStreamPlayer



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
	
	GameManager.victorySFX = winSFX
	
	
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

	_setup_settings_music_slider()


func _setup_settings_music_slider() -> void:
	var music_bus := AudioServer.get_bus_index(_MUSIC_BUS_NAME)
	if music_bus < 0:
		return
	var slider := get_node_or_null(_SETTINGS_MUSIC_SLIDER_PATH) as HSlider
	if slider == null:
		return
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = AudioServer.get_bus_volume_linear(music_bus) * 100.0
	if not slider.value_changed.is_connected(_on_settings_music_volume_changed):
		slider.value_changed.connect(_on_settings_music_volume_changed)


func _on_settings_music_volume_changed(value: float) -> void:
	var music_bus := AudioServer.get_bus_index(_MUSIC_BUS_NAME)
	if music_bus < 0:
		return
	AudioServer.set_bus_volume_linear(music_bus, value / 100.0)


func _on_response_label_gui_input(event: InputEvent) -> void:
	#display card gui
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				animationPlayer.play("DisplayCardGui")
				openMenuSFX.play()


func _on_scenario_label_gui_input(event: InputEvent) -> void:
	#stop displaying card gui
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				animationPlayer.play("HideCardGui")
				closeMenuSFX.play()


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
