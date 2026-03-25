extends MiniGames
class_name MeteorMinigame

@export var survival_time := 30.0
var elapsed := 0.0
var won = false

@onready var spawner = $ObstacleSpawner
@onready var player = $Player

func _ready():
	player.add_to_group("player")

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= survival_time and not won:
		won = true
		performScenarioEffect()

func performScenarioEffect() -> void:
	if won:
		emit_signal("scenarioWon")
		print("Won")
		player.queue_free()
		spawner.stop_spawning()

func getWinCondition() -> String:
	return "Survive for %d seconds." % survival_time
