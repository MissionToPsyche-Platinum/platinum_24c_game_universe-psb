extends Node
class_name MapController

#@export var layout: MapLayout
@export var easy_layout: MapLayout
@export var medium_layout: MapLayout
@export var hard_layout: MapLayout
@export var view: MapView

@export var top_label: Label
@export var map_text := "Select a highlighted scenario to advance."
@export var difficulty_text := "Select a map difficulty."
@export var easy_desc_label: Label
@export var med_desc_label: Label
@export var hard_desc_label: Label
@export var easy_desc := "5+ Scenarios to reach the Psyche asteroid"
@export var med_desc := "7+ Scenarios to reach the Psyche asteroid"
@export var hard_desc := "10+ Scenarios to reach the Psyche asteroid"
@export var scroll_button: Area2D
@export var difficulty_buttons: HBoxContainer

var model: MapModel
var layout: MapLayout
var map_active := true
var scrolled_up := false
var selected_difficulty := false

func _ready():
	if !selected_difficulty: # player hasn't yet selected difficulty
		top_label.text = difficulty_text
		difficulty_buttons.show()
	else: # player has selected difficulty
		if layout.is_scrollable:
			scroll_button.initialize_button()
		model = MapModel.new(layout)
		view.build(layout)
		view.update_from_model(model)

		view.node_clicked.connect(_on_node_clicked)
		model.changed.connect(_on_model_changed)
		model.reached_end.connect(_on_reached_end)

		activate_map_delayed()

func _on_node_clicked(index: int):
	if not map_active:
		return
	# Update player stats for total encounters
	GameManager.stats.situation_encountered()
	
	map_active = false
	self.visible = false
	model.move_to(index)

func _on_model_changed():
	view.update_from_model(model)
	activate_map_delayed()

func activate_map_delayed(delay := 0.5):
	map_active = false
	await get_tree().create_timer(delay).timeout
	map_active = true

func _on_reached_end():
	self.visible = false
	#get_tree().change_scene_to_file("res://Model/ScreenData/WinScreen.tscn")

func advance_position():
	model.advance_position()
	view.update_from_model(model)
	if model.has_won == true:
		self.visible = false
	else:
		self.visible = true
		activate_map_delayed()

# Scroll button helpers
func _on_scroll_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if layout.is_scrollable:
			map_active = false
			if scrolled_up:
				view.position.y = 0
				scrolled_up = false
			else:
				view.position.y = get_viewport().get_visible_rect().size.y
				scrolled_up = true
			rotate_scroll_button()
			map_active = true

func rotate_scroll_button() -> void:
	if scroll_button.is_upright:
		scroll_button.is_upright = false
		scroll_button.position.y = get_viewport().get_visible_rect().size.y 
		scroll_button.scale.y = -1
	else:
		scroll_button.is_upright = true
		scroll_button.position.y = scroll_button.default_pos
		scroll_button.scale.y = 1

# Map difficulty select 

# Helper called by difficulty buttons to load map
func _difficulty_selected() -> void:
	selected_difficulty = true
	top_label.text = map_text
	difficulty_buttons.hide()
	_ready()

# Called when respective difficulty button is presed
func _on_easy_button_pressed() -> void:
	layout = easy_layout
	_difficulty_selected()

func _on_easy_button_mouse_entered() -> void:
	easy_desc_label.text = easy_desc
	easy_desc_label.visible = true

func _on_easy_button_mouse_exited() -> void:
	easy_desc_label.visible = false


func _on_medium_button_pressed() -> void:
	layout = medium_layout
	_difficulty_selected()

func _on_medium_button_mouse_entered() -> void:
	med_desc_label.text = med_desc
	med_desc_label.visible = true

func _on_medium_button_mouse_exited() -> void:
	med_desc_label.visible = false


func _on_hard_button_pressed() -> void:
	layout = hard_layout
	_difficulty_selected()

func _on_hard_button_mouse_entered() -> void:
	hard_desc_label.text = hard_desc
	hard_desc_label.visible = true

func _on_hard_button_mouse_exited() -> void:
	hard_desc_label.visible = false
