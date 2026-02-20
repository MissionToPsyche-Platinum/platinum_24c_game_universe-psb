extends Node
class_name MapController

@export var layout: MapLayout
@export var view: MapView
@onready var scroll_button = $"Scroll Button"
@onready var background = $"TextureRect"


var model: MapModel
var map_active := true
var scrolled_up := false

func _ready():
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


func _on_scroll_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if layout.is_scrollable:
			map_active = false
			if scrolled_up:
				#self.position.y = 0
				#background.position.y = 0
				view.position.y = 0
				scrolled_up = false
			else:
				#self.position.y = get_viewport().get_visible_rect().size.y
				#background.position.y = get_viewport().get_visible_rect().size.y
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
