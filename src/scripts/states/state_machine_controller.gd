extends Node
class_name StateMachineController

@export var player: CharacterBody3D = get_parent()
@export var current_state_config: Dictionary = {
	MovementState: IdleState
}

var states: Dictionary = {} # Dictionary of all States
var parent_states: Array[State] = [] # Array of parent states

### FUNCTIONS
func start_machine(p_player: CharacterBody3D) -> void:
	## Initialize the state machine with the provided initial states
	self.player = p_player
	
	parent_states = [MovementState.new(self.player, self)]
	
	for i in parent_states:
		i._enter()
		states[i.get_state_name()] = i


func _process(_delta: float) -> void:
	pass


func _transition_state(_parent_state_name: String, _cur_child_state_name: String, _new_child_state_name: String) -> void:
	## used to transition between states
	var cur_parent_state: State = states.get(_parent_state_name)
	var cur_child_state: State = states.get(_cur_child_state_name)
	var new_child_state: State = states.get(_new_child_state_name)
	
	cur_child_state._exit()
	new_child_state._enter()
	
	current_state_config[cur_parent_state] = new_child_state
	pass
