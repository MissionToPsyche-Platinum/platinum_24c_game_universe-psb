extends Node
class_name MapController

@export var layout: MapLayout
@export var view: MapView

var model: MapModel
var map_active := true

func _ready():
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
	get_tree().change_scene_to_file("res://Model/ScreenData/WinScreen.tscn")

func advance_position():
	model.advance_position()
	view.update_from_model(model)
	self.visible = true
	activate_map_delayed()
