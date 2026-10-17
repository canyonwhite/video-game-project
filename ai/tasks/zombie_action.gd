@tool
extends BTAction

enum Action { DEAD, STAGGER, ATTACK, CHASE, INVESTIGATE, IDLE, RECOGNIZE }
@export var action: Action = Action.IDLE

func _generate_name() -> String:
	return "Zombie: " + Action.keys()[action]

func _tick(delta: float) -> Status:
	var zombie := agent as PrototypeZombie
	if zombie == null:
		return FAILURE
	match action:
		Action.DEAD: zombie.set_state("DEAD")
		Action.STAGGER: zombie.set_state("STAGGER")
		Action.ATTACK: zombie.tick_attack(delta)
		Action.CHASE: zombie.tick_chase(delta)
		Action.INVESTIGATE: zombie.tick_investigate(delta)
		Action.IDLE: zombie.set_state("IDLE")
		Action.RECOGNIZE: zombie.tick_recognize()
	return RUNNING

func _exit() -> void:
	var zombie := agent as PrototypeZombie
	if zombie != null:
		zombie.desired_velocity = Vector3.ZERO
		if action == Action.ATTACK:
			zombie.attacking = false
