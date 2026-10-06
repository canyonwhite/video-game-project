@tool
extends BTCondition

enum Check { DEAD, STAGGERED, ATTACK, RECOGNIZED, MEMORY, RECOGNIZING }
@export var check: Check = Check.RECOGNIZED

func _generate_name() -> String:
	return "Zombie: " + Check.keys()[check]

func _tick(_delta: float) -> Status:
	var zombie := agent as PrototypeZombie
	if zombie == null:
		return FAILURE
	var result := false
	match check:
		Check.DEAD: result = zombie.dead
		Check.STAGGERED: result = zombie.stagger_left > 0
		Check.ATTACK: result = zombie.attacking or zombie.can_attack()
		Check.RECOGNIZED: result = blackboard.get_var("recognized", false)
		Check.RECOGNIZING: result = blackboard.get_var("recognizing", false)
		Check.MEMORY: result = is_instance_valid(zombie.target) and blackboard.get_var("memory_left", 0.0) > 0
	return SUCCESS if result else FAILURE
