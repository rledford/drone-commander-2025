extends CharacterBody2D
class_name Drone

const ARRIVE_DIST: float = 8.0

@export var type: Enums.DroneType = Enums.DroneType.NONE

var commander: Node


func is_valid_target(node) -> bool:
	return is_instance_valid(node) and node.get_parent() != null
