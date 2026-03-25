extends MiniGames
class_name ShootingMinigame

@export var enemies := 1
var enemies_destroyed := 0

func _ready():
	await get_tree().process_frame
	
	for enemy in get_tree().get_nodes_in_group("UFO"):
		enemy.destroyed.connect(_on_enemy_destroyed)
		
func _on_enemy_destroyed():
	enemies_destroyed += 1
	performScenarioEffect()

func performScenarioEffect() -> void:
	if enemies_destroyed >= enemies:
		emit_signal("scenarioWon")
		$Player.queue_free()
		return

func getWinCondition() -> String:
	return "Eliminate the enemy."
