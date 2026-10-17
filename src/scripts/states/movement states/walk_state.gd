class_name WalkState
extends State

### Walk Child State of Movement

static var state_name: String = "WalkState"

func _enter() -> void:
	## Handle state entry logic
	print("You have entered the walk state")
	pass

func _exit() -> void:
	## Handle state exit logic
	print("You have exited the walk state")
	pass


func get_state_name() -> String:
	return state_name
