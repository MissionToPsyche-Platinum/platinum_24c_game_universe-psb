extends Control

@onready var loseScreenSFX : AudioStreamPlayer = $LoseSFX


func _ready():
	if loseScreenSFX != null:
		loseScreenSFX.play()


func _on_play_again_button_pressed() -> void:
	GameManager.restartGame()
