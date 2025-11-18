extends Area2D

@onready var sprite = $"Battle Scenario"

signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.modulate = Color("f89f00")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	sprite.modulate = Color("ffffff")
	print("Mouse entered sprite")

func _on_mouse_exited() -> void:
	sprite.modulate = Color("f89f00")
	print("Mouse exited sprite")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked on sprite")
			emit_signal("interacted", self)
			get_tree().change_scene_to_file("res://Model/Scenes/scenario_placeholder.tscn")
			print("Changed scene to scenario")
