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
			GameManager.getPlayer().setHullIntegrity(effect.amount)
		elif effect.affectedAttribute == 1:
			GameManager.getPlayer().setPower(effect.amount)
		else:
			GameManager.getPlayer().setVelocity(effect.amount)
	return true;

func isCardPlayable() -> bool:
	#right now just enable every card
	return true

func getBehaviorHint() -> String:
	var hint = ""
	for effect in affectedAttributes:
		if effect.affectedAttribute == 0:
			hint += ("Hull Integrity +" + str(effect.amount) + '\n')
		elif effect.affectedAttribute == 1:
			hint += ("Power +" + str(effect.amount) + '\n')
		else:
			hint += ("Velocity +" + str(effect.amount) + '\n')
		
	
	return hint
	
