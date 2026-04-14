extends ICardBehavior
class_name DefaultBehavior

#denomiator for chance to win scenario
static var chance := 32

func _ready():
	#seed the rng
	randomize()

func use() -> bool:
	
	#check to see if we won the scenario
	var generatedNumber = randi_range(1, chance)
	
	if generatedNumber == 1:
		#won
		#reset chance
		chance = 32
		#beat the scenario
		GameManager.defaultCardWin = true 
		
		
	else:
		#did not win
		if chance != 2:
			chance = chance / 2
		
			
	return true
	
func isCardPlayable() -> bool:
	return true
	
func getBehaviorHint() -> String:
	return "1/" + str(chance) + " to\nbeat the scenario"
 
