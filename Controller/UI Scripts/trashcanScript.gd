extends Control

@export var trashCanAnimationPlayer : AnimationPlayer


func _on_trash_can_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Open":
		trashCanAnimationPlayer.play("IdleOpen")
	if anim_name == "Close":
		trashCanAnimationPlayer.play("IdleClosed")
