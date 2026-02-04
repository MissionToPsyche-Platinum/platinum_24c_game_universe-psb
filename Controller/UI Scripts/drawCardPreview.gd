extends Control
class_name DrawCardPreview

#references to child objects
@export var drawCardPreviewAnimationPlayer: AnimationPlayer
@export var drawCardPreviewHolder: Control

var currentPreview: Node = null

#how much to affect the x and y scale of the previewed card
@export var resizeScaleX: float 
@export var resizeScaleY: float

#function for displaying the drawn card as a preview on the ui
func drawCardPreview(card: PackedScene) -> void:
	if currentPreview and is_instance_valid(currentPreview):
		currentPreview.queue_free()
		
	currentPreview = card.instantiate()
	
	#resize the card for display purposes
	if currentPreview is Control:
		currentPreview.scale.x = resizeScaleX
		currentPreview.scale.y = resizeScaleY
	
	
	
	#add the card to the preview holder
	drawCardPreviewHolder.add_child(currentPreview)
	
	##drawCardPreviewAnimationPlayer.stop()
	drawCardPreviewAnimationPlayer.play("DrawCard")
		
		

func _on_draw_card_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "DrawCard":
		currentPreview.queue_free()
		currentPreview = null
		
		
