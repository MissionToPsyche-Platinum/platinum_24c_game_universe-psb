extends Resource	
class_name AttributeEffect

enum AttributeTypes { HULL_INTEGRITY, POWER, VELOCITY }

@export var affectedAttribute: AttributeTypes
@export var amount: float 
