extends Node
class_name StatsController
# Controller for player stats displayed on win screen

var model: StatsModel

func _ready():
	model = StatsModel.new()

# Called whenever a card is used to increment cards_used
func use_card():
	model.cards_used += 1

# Called whenever a scenario is started to increment total_encounters
func situation_encountered():
	model.total_encounters += 1

# Called on reset to reset stats
func reset_stats():
	model.cards_used = 0
	model.total_encounters = 0
	model.time_elapsed = 0.0

# Helper function to store attributes from game manager 
func store_attributes():
	model.hullIntegrity = GameManager.player.hullIntegrity
	model.velocity = GameManager.player.velocity
	model.power = GameManager.player.power
