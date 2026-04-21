extends MiniGames
class_name MeteorMinigame

@export var survival_time := 30.0
var elapsed := 0.0
var won = false

@onready var spawner = $ObstacleSpawner
@onready var player = $Player

@onready var minigameMusicPlayer : AudioStreamPlayer = $MinigameMusicPlayer

func _ready():
	player.add_to_group("player")
	minigameMusicPlayer.play()

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= survival_time and not won:
		won = true
		performScenarioEffect()

func performScenarioEffect() -> void:
	if won:
		emit_signal("scenarioWon")
		print("Won")
		for child in spawner.get_children():
			if child.is_in_group("obstacles"):
				child.queue_free()
		player.queue_free()
		spawner.stop_spawning()

func getWinCondition() -> String:
	return "Survive for %d seconds." % survival_time


func _on_minigame_music_player_finished() -> void:
	minigameMusicPlayer.play()
