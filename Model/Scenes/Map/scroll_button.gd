extends Area2D

@onready var sprite = $"Sprite2D"
@export var is_active := false
@export var is_upright := true
var layout: MapLayout
var default_pos: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	default_pos = self.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize_button() -> void:
	is_active = true
	sprite.modulate = Color("f89f00")
	self.visible = true

func _on_mouse_entered() -> void:
	sprite.modulate = Color("ffffff")
	print("Mouse entered sprite")

func _on_mouse_exited() -> void:
	sprite.modulate = Color("f89f00")
	print("Mouse exited sprite")
