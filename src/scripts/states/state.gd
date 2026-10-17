@abstract
class_name State
extends Node

###### FUNCTIONS
@abstract func _enter() -> void
@abstract func _exit() -> void

var child_states: Array[State]
var parent_state: State
var player: CharacterBody3D
var state_controller: StateMachineController

func _init(p_player: CharacterBody3D, machine: StateMachineController) -> void:
	self.player = p_player
	self.state_controller = machine

func _get_state_name() -> String:
	push_error("Method get_state_name() must be defined.")
	return ""
