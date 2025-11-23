extends Node2D

@export var player: Player
@export var scenario: Scenario
@export var cardManager: CardManager

@export var hand: Control 

#assign referenes to UI elements
@export var hullIntegrityLabel: Label
@export var powerLabel: Label
@export var velocityLabel: Label

@export var descriptionLabel: Label
@export var effectLabel: Label

@export var hullIntegrityBar : TextureProgressBar
@export var powerBar : TextureProgressBar
@export var velocityBar : TextureProgressBar





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#register all values with the GameManager
	GameManager.player = player
	GameManager.card_manager = cardManager
	GameManager.hand = hand
	
	#assign UI references
	GameManager.hullIntegrityLabel = hullIntegrityLabel
	GameManager.powerLabel = powerLabel
	GameManager.veloctiyLabel = velocityLabel
	GameManager.descriptionLabel = descriptionLabel
	GameManager.effectLabel = effectLabel
	GameManager.hullIntegrityBar = hullIntegrityBar
	GameManager.powerBar = powerBar
	GameManager.velocityBar = velocityBar
	
	
	#load the scenario
	GameManager.loadScenario("res://Model/ScenarioData/Scenarios/Sc_DoubleDarkMatter.tscn")
