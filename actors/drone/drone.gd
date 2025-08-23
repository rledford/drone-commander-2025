extends CharacterBody2D
class_name Drone

const SCRAP: StringName = &"scrap"
const PLAYER: StringName = &"player"
const ENEMY: StringName = &"enemy"
const ARRIVE_DIST: float = 8.0

enum State {
	IDLE,
	PATROL,
	GATHER,
	DROPOFF,
	ATTACK
}

@export var max_speed: float = 100.0
@export var accel: float = 256.0
@export var decel: float = 128.0
@export var patrol_range: float = 256.0
@export var scan_range: float = 256.0
@export var scan_frequency: float = 1.0

var patrol_destination: Vector2
var patrol_target: Node
var state: int = State.IDLE
var scan_times := {} # { StringName: TicksMilliseconds }

func set_state(new_state: int) -> void:
	state = new_state


func is_valid_target(node) -> bool:
	return is_instance_valid(node) and node.get_parent() != null


func is_in_range(node: Node, max_distance: float) -> bool:
	return global_position.distance_squared_to(node.global_position) < pow(max_distance, 2)


func acquire_target_in_range(group: StringName, max_range: float = INF) -> Node:
	if get_tree().get_node_count_in_group(group) == 0:
		return null
	
	var max_range_squared = pow(max_range, 2) if max_range != INF else max_range
	var nodes = get_tree().get_nodes_in_group(group).filter(
		func(node):
			return node.global_position.distance_squared_to(global_position) < max_range_squared
	)
	
	if len(nodes) == 0:
		return null
	
	return nodes.pick_random()


func scan_for_target(group: StringName) -> Node:
	var last_scan_time = scan_times.get(group, 0)
	if Time.get_ticks_msec() - last_scan_time < scan_frequency * 1000.0:
		return
	
	scan_times.set(group, Time.get_ticks_msec())
	
	return acquire_target_in_range(group, scan_range)


func drift(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, decel * delta)


func plan_patrol_destination() -> void:
	if not is_valid_target(patrol_target):
		patrol_destination = Vector2(global_position)
	
	var random_dir = Vector2.RIGHT.rotated(randf() * TAU)
	var random_dist = randf_range(patrol_range * 0.5, patrol_range)
	
	patrol_destination = (
		Vector2(patrol_target.global_position) + random_dir * random_dist
	)


func move_toward_target_node(target: Node, delta: float) -> void:
	move_toward_target_position(target.global_position, delta)


func move_toward_target_position(pos: Vector2, delta: float) -> void:
	var dir = global_position.direction_to(pos)
	
	var is_moving_toward_x = sign(dir.x) == sign(velocity.x)
	var is_moving_toward_y = sign(dir.y) == sign(velocity.y)
	
	velocity.x = move_toward(
		velocity.x, dir.x * max_speed,
		delta * (accel if is_moving_toward_x else decel)
	)

	velocity.y = move_toward(
		velocity.y, dir.y * max_speed,
		delta * (accel if is_moving_toward_y else decel)
	)


func keep_target_at_distance(target: Node, desired_distance: float, tolerance: float, delta: float) -> void:
	var dist = global_position.distance_to(target.global_position)
	var direction_to_move = Vector2.ZERO
	var distance_error: float = 0.0
	
	if dist < desired_distance - tolerance:
		# move away
		direction_to_move = target.global_position.direction_to(global_position)
		distance_error = desired_distance - tolerance - dist
	elif dist > desired_distance + tolerance:
		# move toward
		direction_to_move = global_position.direction_to(target.global_position)
		distance_error = dist - (desired_distance + tolerance)
	else:
		drift(delta)
		return
	
	var speed = clamp(distance_error * 0.5, 0, max_speed)
	var pos = Vector2(global_position + (direction_to_move * speed))
	
	move_toward_target_position(pos, delta)


func has_arrived_at_node(target: Node, arrive_distance: float = ARRIVE_DIST) -> bool:
	return has_arrived_at_position(target.global_position, arrive_distance)


func has_arrived_at_position(pos: Vector2, arrive_distance: float = ARRIVE_DIST) -> bool:
	return global_position.distance_squared_to(pos) <= pow(arrive_distance, 2)
