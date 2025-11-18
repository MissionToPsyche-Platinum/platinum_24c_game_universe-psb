extends Node2D

@export var player: Player
@export var scenario: Scenario
@export var cardManager: CardManager

@export var hand: Control 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#register all values with the GameManager
	GameManager.player = player
	GameManager.scenario = scenario
	GameManager.card_manager = cardManager
	GameManager.hand = hand
