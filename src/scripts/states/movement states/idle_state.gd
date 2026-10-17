class_name IdleState
extends State

static var state_name: String = "IdleState"

func _enter() -> void:
	print("You have entered the idle state")
	pass


func _exit() -> void:
	print("You have exited the idle state")
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func get_state_name() -> String:
	return state_name
