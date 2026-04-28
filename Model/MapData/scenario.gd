extends Area2D

#sprite (changes based on type)
@onready var sprite = $"Battle Scenario"

#used for checking and instantiating scenario scenes
enum ScenarioType { EVENT, BATTLE, MINIGAME }
var type : ScenarioType
var scenario : PackedScene

#list of scenarios available in the game by scenario difficulty
@export var easy_scenarios: Array[PackedScene] = []
@export var med_scenarios: Array[PackedScene] = []
@export var hard_scenarios: Array[PackedScene] = []
#first N nodes of a map that are easy
@export var n_easy_scenarios := 2
#Nth node where scenario difficulty is raised to hard
@export var nth_hard_scenario := 10

#array of scenarios able to be chosen from at random for this node
static var available_scenarios: Array[PackedScene]

#disabled scenario nodes are grey and can't be clicked on
var is_disabled := false
# signals if clicked on (scenario chosen)
signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !is_disabled: #only choose a scenario and update sprite if active
		choose_random_scenario()
		set_sprite()


# Selects random scenario from Scenarios folder and assigns it to this node
func choose_random_scenario():
	#first get list of available scenarios
	#load list if empty (can no longer avoid repeats)
	var total_encounters = GameManager.stats.model.total_encounters
	if available_scenarios.is_empty() or total_encounters == 0:
		load_scenario_list(total_encounters)
	#update list if player crossed difficulty threshold
	update_scenario_list(total_encounters)
	
	#then assign random scenario from those available to this node
	var index = randi() % available_scenarios.size()
	scenario = available_scenarios[index]
	#remove so no repeats
	available_scenarios.remove_at(index)
	
	#get scenarioType (for sprite)
	if scenario:
		var instance = scenario.instantiate()
		type = instance.scenarioType
		instance.queue_free()
	else:
		print("Failed to load scenario scene.")
	
func load_scenario_list(total_encounters):
	#fill available scenarios list w all scenarios in difficulty level
	if total_encounters < n_easy_scenarios:
		available_scenarios = easy_scenarios.duplicate()
	elif total_encounters >= nth_hard_scenario - 1:
		available_scenarios = hard_scenarios.duplicate()
	else:
		available_scenarios = med_scenarios.duplicate()
	
	if available_scenarios.size() == 0:
		print("No scenarios found!")
		return

#called to update scenario list when player crosses difficulty thresholds
func update_scenario_list(total_encounters):
	if total_encounters == nth_hard_scenario - 1:
		available_scenarios = hard_scenarios.duplicate()
	elif total_encounters == n_easy_scenarios:
		available_scenarios = med_scenarios.duplicate()
	#else: no change to available_scenarios since no difficulty change
	
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
