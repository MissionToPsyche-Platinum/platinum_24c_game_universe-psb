extends Control

@export var startGameLabel : Label
@export var tutorialLabel : Label
@export var aboutLabel : Label
@export var creditsLabel : Label
@export var backLabel : Label

@export var menuHoverSound : AudioStreamPlayer2D

@export var creditsAnimationPlayer : AnimationPlayer

#plays the leadup + loop
@export var mainMenuMusicIntroPlayer : AudioStreamPlayer
#plays the loop only
@export var mainMenuMusicLoopPlayer : AudioStreamPlayer

func _ready():
	#label settings are a shared resource, need to duplicate them to edit them seperately 
	startGameLabel.label_settings = startGameLabel.label_settings.duplicate()
	tutorialLabel.label_settings = startGameLabel.label_settings.duplicate()
	aboutLabel.label_settings = startGameLabel.label_settings.duplicate()
	creditsLabel.label_settings = startGameLabel.label_settings.duplicate()
	backLabel.label_settings = startGameLabel.label_settings.duplicate()
	
	#play the music
	mainMenuMusicIntroPlayer.play()
	
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Model/Scenes/MainScene.tscn")


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Model/ScenarioData/ScenarioBases/TutorialScenario.tscn")


func _on_start_button_mouse_entered() -> void:
	startGameLabel.label_settings.font_color = Color('#f89f00')
	menuHoverSound.play()
	

func _on_start_button_mouse_exited() -> void:
	startGameLabel.label_settings.font_color = Color('#fff')
	

func _on_start_game_label_mouse_entered() -> void:
	_on_start_button_mouse_entered()


func _on_start_game_label_mouse_exited() -> void:
	_on_start_button_mouse_exited()


func _on_start_button_focus_entered() -> void:
	_on_start_button_mouse_entered()


func _on_start_game_label_focus_exited() -> void:
	_on_start_button_mouse_exited()


func _on_tutorial_label_mouse_entered() -> void:
	_on_tutorial_button_mouse_entered()


func _on_tutorial_label_mouse_exited() -> void:
	_on_tutorial_button_mouse_exited()


func _on_tutorial_label_focus_entered() -> void:
	_on_tutorial_button_mouse_entered()


func _on_tutorial_label_focus_exited() -> void:
	_on_tutorial_button_mouse_exited()


func _on_about_label_mouse_entered() -> void:
	_on_about_button_mouse_entered()


func _on_about_label_mouse_exited() -> void:
	_on_about_button_mouse_exited()


func _on_about_label_focus_entered() -> void:
	_on_about_button_mouse_entered()


func _on_about_label_focus_exited() -> void:
	_on_about_button_mouse_exited()


func _on_credits_label_mouse_entered() -> void:
	_on_credits_button_mouse_entered()


func _on_credits_label_mouse_exited() -> void:
	_on_credits_button_mouse_exited()


func _on_credits_label_focus_entered() -> void:
	_on_credits_button_mouse_entered()


func _on_credits_label_focus_exited() -> void:
	_on_credits_button_mouse_exited()


func _on_tutorial_button_mouse_entered() -> void:
	tutorialLabel.label_settings.font_color = Color('#f89f00')
	menuHoverSound.play()


func _on_tutorial_button_mouse_exited() -> void:
	tutorialLabel.label_settings.font_color = Color('#fff')
	

func _on_about_button_mouse_entered() -> void:
	aboutLabel.label_settings.font_color = Color('#f89f00')
	menuHoverSound.play()
	
func _on_about_button_mouse_exited() -> void:
	aboutLabel.label_settings.font_color = Color("#fff")

func _on_credits_button_mouse_entered() -> void:
	creditsLabel.label_settings.font_color = Color('#f89f00')
	menuHoverSound.play()

func _on_credits_button_mouse_exited() -> void:
	creditsLabel.label_settings.font_color = Color('#fff')


func _on_back_button_pressed() -> void:
	creditsAnimationPlayer.play_backwards("showCredits")


func _on_back_button_mouse_entered() -> void:
	backLabel.label_settings.font_color = Color('#f89f00')
	menuHoverSound.play()
	

func _on_back_button_mouse_exited() -> void:
	backLabel.label_settings.font_color = Color('#fff')


func _on_credits_button_pressed() -> void:
	creditsAnimationPlayer.play("showCredits")


func _on_intro_music_player_finished() -> void:
	mainMenuMusicLoopPlayer.play()
