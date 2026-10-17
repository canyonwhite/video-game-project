extends CharacterBody3D

@onready var state_machine_controller: StateMachineController = $state_machine_controller

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	state_machine_controller.start_machine(self)


func _process(_delta: float) -> void:
	## Update the state machine controller
	pass


func _physics_process(_delta: float) -> void:
	## Handle physics-related updates for the player
	pass
