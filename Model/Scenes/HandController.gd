extends Control
class_name HandController

@export var cardSpacing := 350
@export var sideScale := 0.7
@export var centerScale := 1.0
@export var card_container_path: NodePath

@export var cardEffectLabel: Label
@export var continueScenarioControl : Control

@export var test_mode: bool = false

var card_container: Control
var cards: Array[Control] = [] 
var selectedIndex := 0

func _ready():
	# In test mode, we manually assign nodes in tests, so skip lookups
	if test_mode:
		return

	# Normal behavior
	card_container = get_node(card_container_path)

func addCard(card_node: Control) -> void:
	# wrap so layout works
	var wrapper := Control.new()
	if not test_mode:
		wrapper.set_custom_minimum_size(Vector2(200, 0))

	wrapper.add_child(card_node)
	card_container.add_child(wrapper)
	cards.append(wrapper)

	# ensure selectedIndex valid
	if cards.size() == 1:
		selectedIndex = 0

	if not test_mode:
		updateLayout()

func removeCard(card_node: Control) -> void:
	# find the wrapper containing this card
	for i in cards.size():
		var wrapper := cards[i]
		if wrapper.get_child(0) == card_node:
			# remove from list
			cards.remove_at(i)

			# fix selected index
			if selectedIndex >= cards.size():
				selectedIndex = max(0, cards.size() - 1)

			wrapper.queue_free()
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
	if selected_card != null and selected_card.get_child_count() > 0 and selected_card.get_child(0) != null and selected_card.get_child(0).has_method("getCardHint"):
		cardEffectLabel.text = selected_card.get_child(0).getCardHint()
	else:
		cardEffectLabel.text = ""

func _on_right_arrow_button_pressed() -> void:
	rotateRight()

func _on_left_arrow_button_pressed() -> void:
	rotateLeft()

func _on_select_response_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if cards.is_empty():
			return
		if not test_mode:
			# Hide the GUI
			GameManager.UIAnimationPlayer.play("UseCard")

			# Tween out the scenario header label to replace its text
			var tween = create_tween()
			tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,0), 0.25)
			await tween.finished

			# Change the text after fade-out completes
			GameManager.scenarioHeader.text = cards[selectedIndex].get_child(0).getCardUseHeader()

			# Fade back in
			tween = create_tween()
			tween.tween_property(GameManager.scenarioHeader, "modulate", Color(1,1,1,1), 0.25)

		# Use the card
		var card := cards[selectedIndex].get_child(0)
		card.use()

		# Allow the player to click anywhere on screen to continue the scenario
		continueScenarioControl.visible = true

func _on_continue_scenario_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Disable the continue scenario control
		continueScenarioControl.visible = false

		# End the player's turn
		GameManager.endPlayerTurn()
		
func resetHandController() -> void:
	#clear the hand 
	cards.clear()
	#remove all children from the card container
	for child in card_container.get_children():
		card_container.remove_child(child)
