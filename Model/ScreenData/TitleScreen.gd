extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Model/Scenes/MainScene.tscn")


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Model/ScenarioData/ScenarioBases/TutorialScenario.tscn")
