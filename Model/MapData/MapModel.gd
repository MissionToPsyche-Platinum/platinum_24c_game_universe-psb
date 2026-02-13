extends Object
class_name MapModel

signal changed
signal reached_end

var layout: MapLayout
var current_index := -1
var known_nodes := {}      # index -> true
var disabled_nodes := {}   # index -> true for disabled scenarios

var psyche_anticipated_index := -1

func _init(map_layout: MapLayout):
	layout = map_layout
	current_index = layout.start_index
	known_nodes[current_index] = true

	# First adjacent nodes are initially known
	for n in get_proceeding_neighbors(current_index):
		known_nodes[n] = true


# Move Psyche only if the node is adjacent
func move_to(index: int):
	if !get_proceeding_neighbors(current_index).has(index):
		return
	psyche_anticipated_index = index

# Called when returning from a scenario
func advance_position():
	if psyche_anticipated_index == -1:
		return

	# Move Psyche
	current_index = psyche_anticipated_index
	psyche_anticipated_index = -1
	disabled_nodes.clear()

	# Disable all known scenarios except current
	for k in known_nodes.keys():
		#if k != current_index:
		disabled_nodes[k] = true
		
	# Check for win
	if get_preceeding_neighbors(layout.end_index).has(current_index):
		reached_end.emit()

	# Reveal all adjacent unknown nodes
	for n in get_proceeding_neighbors(current_index):
		known_nodes[n] = true
		disabled_nodes.erase(n) # newly revealed nodes are active

	#changed.emit()

	# Check for win
	#if get_proceeding_neighbors(current_index).has(layout.end_index):
		#reached_end.emit()

func get_proceeding_neighbors(index: int) -> Array[int]:
	var neighbors: Array[int] = []
	for c in layout.connections:
		if c.x == index:
			neighbors.append(c.y)
	return neighbors
	
func get_preceeding_neighbors(index: int) -> Array[int]:
	var neighbors: Array[int] = []
	for c in layout.connections:
		if c.y == index:
			neighbors.append(c.x)
	return neighbors

func is_node_active(index: int) -> bool:
	return known_nodes.has(index) and !disabled_nodes.has(index)
