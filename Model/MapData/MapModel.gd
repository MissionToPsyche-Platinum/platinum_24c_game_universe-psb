extends Object
class_name MapModel
# MapModel class is used as a part of the map's MVC structure
# Initialzed based on a particular MapLayout

signal changed
signal reached_end

var layout: MapLayout

var current_index := -1
var known_nodes := {}
var disabled_nodes := {}

# Initialize layout, current index & earth node
func _init(map_layout: MapLayout):
	# Initialize layout, index, known node (earth)
	layout = map_layout
	current_index = layout.start_index
	known_nodes[current_index] = true
	
	# Reveal initial neighbors
	for n in get_proceeding_neighbors(current_index):
		known_nodes[n] = true

# Helper to get all proceeding neighbors of index
func get_proceeding_neighbors(index: int) -> Array[int]:
	var neighbors: Array[int] = []
	for c in layout.connections:
		if c.x == index:
			neighbors.append(c.y)
	return neighbors

# Helper to determine viable moves from index
func can_move_to(index: int) -> bool:
	return get_proceeding_neighbors(current_index).has(index)

# Changes current_index to index only if it is a neighbor
func move_to(index: int):
	if !can_move_to(index):
		return

	current_index = index
	known_nodes[index] = true
	changed.emit() # Index has changed (Psyche moves)

	if index == layout.end_index:
		reached_end.emit() # Asteroid has been reached
