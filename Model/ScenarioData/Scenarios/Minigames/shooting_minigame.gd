extends MiniGames
class_name ShootingMinigame

@export var enemies := 1
var enemies_destroyed := 0

@onready var minigameMusicPlayer : AudioStreamPlayer = $MinigameMusicPlayer

func _ready():
	# UFOSpawner spawns the UFO via call_deferred; one process_frame is not always enough
	# for the UFO to exist when we scan the group, so wait until at least one is present.
	var tree := get_tree()
	var safety := 120
	while tree.get_nodes_in_group("UFO").is_empty():
		await tree.process_frame
		safety -= 1
		if safety <= 0:
			push_error("ShootingMinigame: no UFO appeared in group UFO (check UFOSpawner).")
			return

	for enemy in tree.get_nodes_in_group("UFO"):
		if not enemy.destroyed.is_connected(_on_enemy_destroyed):
			enemy.destroyed.connect(_on_enemy_destroyed)
			
	minigameMusicPlayer.play()
		
func _on_enemy_destroyed():
	enemies_destroyed += 1
	performScenarioEffect()

func performScenarioEffect() -> void:
	if enemies_destroyed >= enemies:
		emit_signal("scenarioWon")
		$Player.queue_free()
		
		#stop playing music
		minigameMusicPlayer.stop()
		
		return

func getWinCondition() -> String:
	return "Eliminate the enemy."


func _on_minigame_music_player_finished() -> void:
	minigameMusicPlayer.play()
