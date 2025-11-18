extends ICardBehavior
class_name AttributeBehavior

enum attributeTypes {HULLINEGRITY, POWER, VELOCITY}

@export var affectedAttributes: Array[AttributeEffect]

func use()-> bool:
	#first check if behavior is vaild
	if(!isCardPlayable()):
		print("Card cannot be used!")
		return false
		
	for effect in affectedAttributes:
		if effect.affectedAttribute == 0:
			print("Changing Hull Integrity by " + str(effect.amount))
		elif effect.affectedAttribute == 1:
			print("Changing Power by " + str(effect.amount))
		else:
			print("Changing Velocity by " + str(effect.amount))
			
	return true;

func isCardPlayable() -> bool:
	#right now just disable every card
	return true
