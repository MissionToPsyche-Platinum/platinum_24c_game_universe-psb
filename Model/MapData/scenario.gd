extends Area2D

@onready var sprite = $"Battle Scenario"

enum ScenarioType { EVENT, BATTLE, MINIGAME }
var type : ScenarioType
var scenario_path : String

var is_disabled := false
signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	choose_random_scenario()
	set_sprite()

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
	# once more scenarios are added, probably want to exclude
	# already selected scenarios
	var random_index = randi() % files.size()
	scenario_path = files[random_index]
	print("Selected scenario: ", scenario_path)

# set sprite based on scenario type
func set_sprite():
	match type:
		ScenarioType.BATTLE:
			sprite.texture = preload("res://View/Assets/Sprites/Map/ufo_scenario_icon_white.png")
		ScenarioType.EVENT:
			sprite.texture = preload("res://View/Assets/Sprites/Map/meteroid_scenario_icon_white.png")
		ScenarioType.MINIGAME:
			sprite.texture = preload("res://View/Assets/Sprites/Map/joycon_scenario_icon_white.png")
	sprite.modulate = Color("f89f00") # base color

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

# called once nodes are inaccessible
func disable():
	sprite.modulate = Color("383838")
	# Disconnect mouse enter/exit, input_event
	if is_connected("mouse_entered", Callable(self, "_on_mouse_entered")):
		disconnect("mouse_entered", Callable(self, "_on_mouse_entered"))   
	if is_connected("mouse_exited", Callable(self, "_on_mouse_exited")):
		disconnect("mouse_exited", Callable(self, "_on_mouse_exited"))
	if is_connected("input_event", Callable(self, "_on_input_event")):
		disconnect("input_event", Callable(self, "_on_input_event"))
	is_disabled = true
