extends Node
class_name MovementComponent

@export var stop_threshold: float = 0.5
@export var velocity_component: VelocityComponent


func drift() -> void:
	velocity_component.decelerate()


func move_toward_node(to: Node) -> void:
	move_toward_position(to.global_position)


func move_toward_position(to: Vector2) -> void:
	var dir = get_parent().global_position.direction_to(to)
	
	velocity_component.accelerate_to_velocity(
		velocity_component.get_max_velocity(dir)
	)


func keep_distance_node(to: Node, desired_distance: float, tolerance: float) -> void:
	var global_position: Vector2 = get_parent().global_position
	var dist = to.distance_to(global_position)
	# var direction_to_move = Vector2.ZERO
	var distance_error: float = 0.0
	
	if dist < desired_distance - tolerance:
		# move away
		# direction_to_move = to.global_position.direction_to(global_position)
		distance_error = desired_distance - tolerance - dist
	elif dist > desired_distance + tolerance:
		# move toward
		# direction_to_move = global_position.direction_to(to.global_position)
		distance_error = dist - (desired_distance + tolerance)
	else:
		drift()
	
	# var speed = clamp(distance_error, 0, velocity_component.max_speed)
	# var pos = Vector2(global_position + (direction_to_move * speed))
	
	move_toward_position(to.global_position)


func keep_range_node(to: Node, desired_range: float, _delta: float) -> void:
	var global_position = get_parent().global_position
	var dist_squared = global_position.distance_squared_to(to.global_position)
	if dist_squared < pow(desired_range, 2):
		return
	
	var direction_to_move = global_position.direction_to(to.global_position)
	var distance_error = sqrt(dist_squared) - desired_range
	var speed = clamp(distance_error, 0, velocity_component.max_speed)
	var pos = Vector2(global_position + (direction_to_move * speed))
	
	move_toward_position(pos)


func has_arrived_at_node(to: Node, arrive_distance: float) -> bool:
	return has_arrived_at_position(get_parent().global_position, to.global_position, arrive_distance)


func has_arrived_at_position(from_pos: Vector2, to_pos: Vector2, arrive_distance: float) -> bool:
	return from_pos.distance_squared_to(to_pos) <= pow(arrive_distance, 2)


func is_stopped() -> bool:
	return velocity_component.velocity.length_squared() < pow(stop_threshold, 2)
