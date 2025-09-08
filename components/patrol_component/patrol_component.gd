extends Node
class_name PatrolComponent


const RUN_STATE = &"run"
const IDLE_STATE = &"idle"

@export var movement_component: MovementComponent
@export var patrol_radius: float = 192.0
@export var arrive_distance: float = 5.0

var target_node: Node
var destination: Vector2 = Vector2.INF
var state_machine: CallableStateMachine

func _ready() -> void:
	state_machine = CallableStateMachine.new()
	state_machine.add_state(RUN_STATE, _on_enter_run, _on_update_run, Callable())
	state_machine.add_state(IDLE_STATE, Callable(), _on_update_idle, Callable())
	state_machine.change_state(IDLE_STATE)


func _on_enter_run() -> void:
	_plan_destionation()


func _on_update_run(_delta: float) -> void:
	if movement_component.has_arrived_at_position(
		get_parent().global_position,
		destination,
		arrive_distance
	):
		return state_machine.change_state(IDLE_STATE)
	
	movement_component.move_toward_position(destination)


func _on_update_idle(_delta: float) -> void:
	movement_component.drift()
	if movement_component.is_stopped() and is_instance_valid(target_node):
		return state_machine.change_state(RUN_STATE)


func reset() -> void:
	target_node = null
	destination = Vector2.INF


func update(delta: float) -> void:
	state_machine.update(delta)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	var parent_node = get_parent()
	
	if not parent_node:
		warnings.append("This node requires a parent")
	elif not parent_node.is_class("Node2D"):
		warnings.append("This node must be the child 'Node2D' node")
	
	return warnings

func _plan_destionation() -> void:
	var random_dir = Vector2.RIGHT.rotated(randf() * TAU)
	var random_dist = randf_range(patrol_radius * 0.5, patrol_radius)
	
	destination = (
		Vector2(target_node.global_position) + random_dir * random_dist
	)
