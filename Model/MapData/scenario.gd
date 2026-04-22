extends Area2D

@onready var sprite = $"Battle Scenario"

enum ScenarioType { EVENT, BATTLE, MINIGAME }
var type : ScenarioType
var scenario : PackedScene

#static var available_scenarios := []
@export var all_scenarios: Array[PackedScene] = []
var available_scenarios: Array[PackedScene]

var is_disabled := false
signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	choose_random_scenario()
	set_sprite()


# Selects random scenario from Scenarios folder and assigns it to this node
func choose_random_scenario():
	if available_scenarios.is_empty():
		load_scenario_list() # refill
	#assign random scenario to this node
	var index = randi() % available_scenarios.size()
	scenario = available_scenarios[index]
	#remove so no repeats
	available_scenarios.remove_at(index)
	
	#get scenarioType
	if scenario:
		var instance = scenario.instantiate()
		type = instance.scenarioType
		instance.queue_free()
	else:
		print("Failed to load scenario scene.")
	
func load_scenario_list():
	#fill available scenarios list w all scenarios
	available_scenarios = all_scenarios
	
	if available_scenarios.size() == 0:
		print("No scenarios found!")
		return

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

func _on_mouse_exited() -> void:
	sprite.modulate = Color("f89f00")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked on sprite")
			emit_signal("interacted", self)
			GameManager.loadScenario(scenario)
			#get_tree().change_scene_to_file("res://Model/ScenarioData/Scenarios/MiniGame.tscn")
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
