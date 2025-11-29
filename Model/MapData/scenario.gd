extends Area2D

@onready var sprite = $"Battle Scenario"

var scenario_path : String

signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.modulate = Color("f89f00")
	choose_random_scenario()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Selects random scenario from Scenarios folder and assigns it to this node
func choose_random_scenario():
	# Access Scenarios directory
	var dir = DirAccess.open("res://Model/ScenarioData/Scenarios")
	if dir == null:
		print("Failed to open scenario folder")
		return
	
	# Gather scenario filenames
	dir.list_dir_begin()
	var files := []
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with(".tscn"):
			files.append("res://Model/ScenarioData/Scenarios/" + filename)
		filename = dir.get_next()
	dir.list_dir_end()
	
	if files.size() == 0:
		print("No scenarios found!")
		return
	
	# Pick a random scenario
	var random_index = randi() % files.size()
	scenario_path = files[random_index]
	print("Selected scenario: ", scenario_path)

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
			GameManager.loadScenario(scenario_path)
			#get_tree().change_scene_to_file("res://Model/Scenes/scenario_placeholder.tscn")
			print("Changed scene to scenario")
