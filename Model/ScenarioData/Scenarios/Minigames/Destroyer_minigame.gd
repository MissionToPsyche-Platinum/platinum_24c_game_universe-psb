extends MiniGames
class_name DestroyerMinigame

@onready var brick_scene = preload("res://Model/Scenes/Brick.tscn")
@onready var minigameMusicPlayer : AudioStreamPlayer = $MinigameMusicPlayer

var remaining_bricks: int = 0

func _ready():
	place_bricks()
	minigameMusicPlayer.play()

func place_bricks():
	var rows = 8
	var columns = 9
	var start_x = 490
	var start_y = 150
	var spacing_x = 70
	var spacing_y = 40

	for i in range(rows):
		for j in range(columns):
			var brick = brick_scene.instantiate()
			brick.position = Vector2(
				start_x + j * spacing_x,
				start_y + i * spacing_y
			)
			# Connect the brick destroyed signal
			brick.connect("brick_destroyed", Callable(self, "_on_brick_destroyed"))
			add_child(brick)
			remaining_bricks += 1

func _on_brick_destroyed():
	remaining_bricks -= 1
	if remaining_bricks <= 0:
		performScenarioEffect()

func performScenarioEffect() -> void:
	emit_signal("scenarioWon")
	print("Won")
	$Player.queue_free()
	$Ball.queue_free()

func getWinCondition() -> String:
	return "Destroy The Bricks"


func _on_minigame_music_player_finished() -> void:
	minigameMusicPlayer.play()
