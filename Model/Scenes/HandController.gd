extends Control
class_name HandController

@export var cardSpacing := 350
@export var sideScale := 0.7
@export var centerScale := 1.0
@export var card_container_path: NodePath

@export var cardEffectLabel: Label
@export var continueScenarioControl : Control

@export var test_mode: bool = false

#text that shows when cards are discarded
@export var discardLabel: String

@export var discardCardButtonAnimationPlayer: AnimationPlayer

@export var trashcanAnimationPlayer: AnimationPlayer
#boolean to check if the trash can is in the open or closed position
var trashCanOpened := false

var card_container: Control
var cards: Array[Control] = [] 
var selectedIndex := 0

#Dictionary set to track which cards are currently toggled for discarding
var holdingDiscards := {}

#the header that is displayed when the discard button is used
@export var discardUseHeader : String

func _ready():
	# In test mode, we manually assign nodes in tests, so skip lookups
	if test_mode:
		return

	# Normal behavior
	card_container = get_node(card_container_path)

func addCard(card_node: Control) -> void:
	## Old card settup where Control Wrappers were needed 
	#var wrapper := Control.new()
	#if not test_mode:
		#wrapper.set_custom_minimum_size(Vector2(200, 0))
#
	#wrapper.add_child(card_node)
	#card_container.add_child(wrapper)
	#cards.append(wrapper)
	
	card_container.add_child(card_node)
	cards.append(card_node)
	
	# ensure selectedIndex valid
	if cards.size() == 1:
		selectedIndex = 0

	if not test_mode:
		updateLayout()

func removeCard(card_node: Control) -> void:
	#remove the card from the hand controller
	cards.erase(card_node)
	
	#delete the card
	card_node.queue_free()

	# fix selected index
	if selectedIndex >= cards.size():
		selectedIndex = max(0, cards.size() - 1)

	#update the layout
	updateLayout()
	return

func rotateLeft() -> void:
	if cards.size() <= 1:
		return

	selectedIndex = (selectedIndex - 1 + cards.size()) % cards.size()
	updateLayout()

func rotateRight() -> void:
	if cards.size() <= 1:
		return

	selectedIndex = (selectedIndex + 1) % cards.size()
	updateLayout()

func updateLayout() -> void:
	if test_mode:
		return

	if cards.size() == 0 or selectedIndex >= cards.size():
		return  # nothing to layout

	for i in range(cards.size()):
		var card := cards[i]
		if card == null:
			continue  # skip null wrapper

		var offset := i - selectedIndex
		if offset > cards.size() / 2:
			offset -= cards.size()
		elif offset < -cards.size() / 2:
			offset += cards.size()

		var targetPos := Vector2(offset * cardSpacing, 0)
		var targetScale := centerScale if offset == 0 else sideScale
		var targetRotation := deg_to_rad(offset * -10)

		if abs(offset) > 2 and cards.size() > 4:
			card.modulate = Color(1,1,1,0)
		else:
			card.modulate = Color(1,1,1,1)

		if not test_mode:
			var tween := create_tween()
			tween.tween_property(card, "position", targetPos, 0.25)
			tween.tween_property(card, "scale", targetScale, 0.25)
			tween.tween_property(card, "rotation", targetRotation, 0.25)

	# --- safely update label ---
	if selectedIndex >= cards.size():
		cardEffectLabel.text = ""
		return

	var selected_card := cards[selectedIndex]
	if selected_card != null:
		cardEffectLabel.text = selected_card.getCardHint()
	else:
		cardEffectLabel.text = ""
		
		
	#check if the card is tagged for discard
	if holdingDiscards.has(cards[selectedIndex]):
		#if yes, check if we need to show that it is
		if !trashCanOpened:
			trashcanAnimationPlayer.play("Open")
			trashCanOpened = true
			
	else:
		#if it is not, check if we need to close the can
		if trashCanOpened:
			trashcanAnimationPlayer.play("Close")
			trashCanOpened = false

func _on_right_arrow_button_pressed() -> void:
	rotateRight()

func _on_left_arrow_button_pressed() -> void:
	rotateLeft()

func _on_select_response_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if cards.is_empty():
			return
			# Grab the card
		var card := cards[selectedIndex]
	
		#first check if card can be played
		if !(card.isCardPlayable()):
			#TODO: give user an error message
			print("Cannot use this card!")
			return 
			
		#check for test mode
		if not test_mode:
			fadeOutUI(cards[selectedIndex].getCardUseHeader())
			

		#get the card use text
		var cardUseText = card.getCardUseHeader()
		
		await card.use()
		
		# Tween out the scenario header label to replace its text
		var tween = create_tween()
		tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,0), 0.25)
		await tween.finished

		# Change the text after fade-out completes
		GameManager.scenarioHeader.text = cardUseText 

		# Fade back in
		tween = create_tween()
		tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,1), 0.25)

		# Allow the player to click anywhere on screen to continue the scenario
		continueScenarioControl.visible = true

func _on_continue_scenario_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Disable the continue scenario control
		continueScenarioControl.visible = false

		#clear the holding discards
		holdingDiscards.clear()

		#play the hide animation for the discard button
		discardCardButtonAnimationPlayer.play("Hide")
		# End the player's turn
		GameManager.endPlayerTurn()
		
func resetHandController() -> void:
	#clear the hand 
	cards.clear()
	#remove all children from the card container
	for child in card_container.get_children():
		card_container.remove_child(child)


func _on_toggle_discard_button_pressed() -> void:
	#save how many cards were are currently in holding discards
	var numberOfDiscardsBeforeToggle = holdingDiscards.size()
	
	#check if the card is toggled for discarding
	#if yes, untoggle it
	if holdingDiscards.has(cards[selectedIndex]):
		holdingDiscards.erase(cards[selectedIndex])
		if not test_mode:
			trashcanAnimationPlayer.play("Close")
		trashCanOpened = false
	else:
		#fuckin weird ass syntax for adding something to a Dictonary 
		holdingDiscards[cards[selectedIndex]] = true
		if not test_mode:
			trashcanAnimationPlayer.play("Open")
		trashCanOpened = true
	
	#after which check if the discard button needs to be shown 
	if numberOfDiscardsBeforeToggle == 0 and holdingDiscards.size() == 1:
		if not test_mode:
			discardCardButtonAnimationPlayer.play("Startup")
	elif holdingDiscards.size() == 0:
		if not test_mode:
			discardCardButtonAnimationPlayer.play("Hide")
	


func _on_discard_button_pressed() -> void:
	#count how many cards are in the holding discard pile
	var holdingDiscardCount = holdingDiscards.size()
	#Player cannot discard every card in their hand, must have at least one to play
	if holdingDiscardCount >= cards.size():
		print("Cannot Discard all cards in your hand!")
		return 
		
	#remove all cards in the holdingDiscards from the player's hand
	for card in holdingDiscards:
		GameManager.player.discardCard(card)
	
	#have the player draw the same amount of cards they discarded
	for i in range(holdingDiscardCount):
		GameManager.player.drawCard(false)
		

	#clear the holding discards
	holdingDiscards.clear()
	
	#returning for test
	if test_mode:
		return  
	
	#Fade out the UI
	fadeOutUI(discardLabel)
	
	
	# Tween out the scenario header label to replace its text
	var tween = create_tween()
	tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,0), 0.25)
	await tween.finished

	# Change the text after fade-out completes
	GameManager.scenarioHeader.text = discardUseHeader

	# Fade back in
	tween = create_tween()
	tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,1), 0.25)
	
	#let the player click anywhere to continue 
	continueScenarioControl.visible = true
	
	
		
func fadeOutUI(uiText : String) -> void:
	# Hide the GUI
		GameManager.UIAnimationPlayer.play("UseCard")

		
	
