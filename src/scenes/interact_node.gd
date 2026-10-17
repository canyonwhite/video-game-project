extends Node3D

@onready var interact_area: Area3D = $Area3D
var type: String = "Laptop"

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(str(body.get_path()))
	print("Can Interact")
	if body.is_in_group("Player"):
		body.can_interact = true
		body.interact_type = type
	return


func _on_area_3d_body_exited(body: Node3D) -> void:
	print("Cannot Interact")
	if body.is_in_group("Player"):
		body.can_interact = false
		body.interact_type = ""
	return
