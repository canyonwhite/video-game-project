class_name MovementState
extends State

var active_child_state: State
var child_state_history: Array[State]

#### Movement Parent State
static var state_name: String = "MovementState"

func get_state_name() -> String:
	return state_name

func _enter() -> void:
	## Handle state entry logic
	child_states = [
		IdleState.new(self.player, self.state_controller),
		WalkState.new(self.player, self.state_controller)
	]
	
	for i in child_states:
		self.state_controller.states[i.get_state_name()] = i
	
	child_states[0]._enter()
	active_child_state = child_states[0]
	child_state_history.append(active_child_state)
	return

func _exit() -> void:
	## Handle state exit logic
	pass
