extends Resource
class_name ArsenalState

signal updated

@export var gather_capacity: int = 3
@export var max_damage: int = 3
@export var max_support: int = 3


var commander: Node
var gather_drones: Array[Node] = []
var damage_drones: Array[Node] = []
var support_drones: Array[Node] = []


func add_gather_drone(drone: Node) -> void:
	_add(gather_drones, drone)


func add_damage_drone(drone: Node) -> void:
	_add(damage_drones, drone)


func add_support_drone(drone: Node) -> void:
	_add(support_drones, drone)


func remove_gather_drone(drone: Node) -> void:
	_remove(gather_drones, drone)


func remove_damage_drone(drone: Node) -> void:
	_remove(damage_drones, drone)


func remove_support_drone(drone: Node) -> void:
	_remove(support_drones, drone)


func has_gather_capacity() -> bool:
	return len(gather_drones) < gather_capacity


func has_damage_capacity() -> bool:
	return len(damage_drones) < max_damage


func has_support_capacity() -> bool:
	return len(support_drones) < max_support


func _add(to: Array[Node], node: Node) -> void:
	to.append(node)
	node.set(&"commander", commander)
	updated.emit()


func _remove(from: Array[Node], node: Node) -> void:
	var index: int = from.find(node)
	if index < 0: return
	from.remove_at(index)
	updated.emit()
