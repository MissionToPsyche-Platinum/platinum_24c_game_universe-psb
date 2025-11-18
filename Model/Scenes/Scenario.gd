extends Node
class_name Scenario

func performScenarioEffect() -> void:
	print("scenario turn started")
	await get_tree().create_timer(1.5).timeout
	print("Wait done")
	GameManager.getPlayer().setHullIntegrity(-10)
	print("Scenario effect done")
