extends Control

@export var discardButtonAnimationPlayer: AnimationPlayer


func _on_discard_button_animation_player_animation_finished(anim_name: StringName) -> void:
	#swap to the idle animation once startup animation is finished, and enable the button
	if anim_name == "Startup":
		discardButtonAnimationPlayer.play("Idle")
	#enable button
	
	
