extends Resource
class_name MapLayout
# MapLayout class is used for map resource files, gets utilized in MapModel 
# to store particular maps

@export var node_positions: Array[Vector2]
@export var connections: Array[Vector2i] # (from, to)
@export var start_index := 0

var end_index: int

func _init():
	if node_positions.size() > 0:
		end_index = node_positions.size() - 1
	else:
		end_index = -1
