extends Node2D

const PsycheScene = preload("res://Model/Scenes/Map/psyche.tscn")
const EarthScene = preload("res://Model/Scenes/Map/earth.tscn")
const PsycheAsteroidScene = preload("res://Model/Scenes/Map/psyche_asteroid.tscn")
const BattleScenarioScene = preload("res://Model/Scenes/Map/battle_scenario.tscn")
const UnknownScenarioScene = preload("res://Model/Scenes/Map/unknown_scenario.tscn")
const LineTexture = preload("res://View/Assets/Sprites/Map/line_texture.png")

const TOTAL_NODES = 9
var node_coordinates = []

var battle_scenarios = []
var unknown_scenarios = []
var earth_node : Node2D
var asteroid_node : Node2D
var psyche_node : Node2D
var lines = []

var selected_scenario : Node2D
var psyche_anticipated_location : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gen_node_coordinates()
	gen_lines()
	gen_scenarios()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called in _ready() to generate node coordinates
func gen_node_coordinates():
	var x = [200, 375, 750, 675, 850, 1225, 1224, 1500, 1675]
	var y = [900, 525, 850, 250, 525, 900, 350, 625, 200]
	for i in range(TOTAL_NODES):
		node_coordinates.append(Vector2(x[i], y[i]))

func gen_lines():
	add_line(node_coordinates[0]*0.9, node_coordinates[1]*0.9)
	add_line(node_coordinates[0], node_coordinates[2])
	add_line(node_coordinates[1], node_coordinates[3])
	add_line(node_coordinates[1], node_coordinates[4])
	add_line(node_coordinates[2], node_coordinates[4])
	add_line(node_coordinates[2], node_coordinates[5])
	add_line(node_coordinates[3], node_coordinates[6])
	add_line(node_coordinates[4]*0.9, node_coordinates[6]*0.9)
	add_line(node_coordinates[4], node_coordinates[7])
	add_line(node_coordinates[5], node_coordinates[7])
	add_line(node_coordinates[6], node_coordinates[8])
	add_line(node_coordinates[7], node_coordinates[8])


# Called in _ready() to populate map with scenarios
func gen_scenarios():
	var i = 0
	#add_line(node_coordinates[0], node_coordinates[1])
	for node in node_coordinates:
		if i == 0:
			add_earth(node.x, node.y)
			add_psyche(node.x+50, node.y-50)
		elif i == TOTAL_NODES-1:
			add_asteroid(node.x, node.y)
		elif i == 1 or i == 2:
			add_battle_scenario(node.x, node.y)
		else:
			add_unknown_scenario(node.x, node.y)
		i = i + 1

# Call in gen_scenarios() to add Psyche spacecraft to map
func add_psyche(x: int, y: int):
	var inst = PsycheScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	psyche_node = inst

# Call in gen_scenarios() to add battle scenarios to map
func add_battle_scenario(x: int, y: int):
	var inst = BattleScenarioScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	inst.connect("interacted", Callable(self, "_on_child_interacted"))
	battle_scenarios.append(inst)

# Call in gen_scenarios() to add unknown (?) scenarios to map
func add_unknown_scenario(x: int, y: int):
	var inst = UnknownScenarioScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	unknown_scenarios.append(inst)

# Call in gen_scenarios() to add Earth to map
func add_earth(x: int, y: int):
	var inst = EarthScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	earth_node = inst

# Call in gen_scenarios() to add Psyche Asteroid to map
func add_asteroid(x: int, y: int):
	var inst = PsycheAsteroidScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	asteroid_node = inst

func add_line(start: Vector2, end: Vector2):
	var inst = Line2D.new()
	add_child(inst)
	inst.add_point(start)
	inst.add_point(end)
	inst.default_color = Color(0.5, 0.5, 0.5)
	inst.width = 5
	#inst.texture = LineTexture
	lines.append(inst)

# Recieves signal from battle scenario node when clicked on
# Then sets selected scenario and anticipated location
func _on_child_interacted(clicked_battle_scenario):
	selected_scenario = battle_scenarios[battle_scenarios.find(clicked_battle_scenario)]
	psyche_anticipated_location = selected_scenario.position
	print("Anticipated location set")
