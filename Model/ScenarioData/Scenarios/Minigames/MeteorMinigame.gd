extends MiniGames
class_name MeteorMinigame

@export var survival_time := 30.0
var elapsed := 0.0
var won = false

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= survival_time:
		if won == false:
			won = true
			performScenarioEffect()
	
func performScenarioEffect() -> void:
	if won == true:
		emit_signal("scenarioWon")
		print("Won")
		$Player.queue_free()
		$ObstacleSpawner.stop_spawning()
		return

func getWinCondition() -> String:
	return "Survive for %d seconds." % survival_time
