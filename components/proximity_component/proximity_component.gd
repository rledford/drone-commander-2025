extends Node
class_name ProximityComponent

@export var scan_range: float = 1.0
@export var scan_frequency_limit: float = 0.0

var _scan_times = {}

func is_in_range(node: Node, max_distance: float) -> bool:
	var pos: Vector2 = get_parent().global_position
	return pos.distance_squared_to(node.global_position) < pow(max_distance, 2)


func get_targets_in_range_sorted(group: StringName, max_distance: float) -> Array:
	if get_tree().get_node_count_in_group(group) == 0:
		return []
	
	var range_target_map = {}
	var pos: Vector2 = get_parent().global_position
	var scan_range2 = pow(max_distance, 2) if max_distance != INF else max_distance
	
	for node in get_tree().get_nodes_in_group(group):
		if node == self:
			continue
		
		var dist2 = node.global_position.distance_squared_to(pos)
		if dist2 < scan_range2:
			range_target_map[dist2] = node
	
	var range_target_keys = range_target_map.keys()
	range_target_keys.sort()
	
	return range_target_keys.map(func(k) -> Node:
		return range_target_map[k]
	)


func acquire_closest_target(group: StringName, max_distance: float) -> Node:
	var nodes = get_targets_in_range_sorted(group, max_distance)
	
	if len(nodes) == 0:
		return null
	
	return nodes[0]


func acquired_farthest_target(group: StringName, max_distance: float) -> Node:
	var nodes = get_targets_in_range_sorted(group, max_distance)
	
	if len(nodes) == 0:
		return null
	
	return nodes[len(nodes) - 1]


func acquire_random_target(group: StringName, max_distance: float) -> Node:
	var nodes = get_targets_in_range_sorted(group, max_distance)
	
	if len(nodes) == 0:
		return null
	
	return nodes.pick_random()


func scan_for_target(group: StringName) -> Node:
	var last_scan_time = _scan_times.get(group, 0)
	if Time.get_ticks_msec() - last_scan_time < scan_frequency_limit * 1000.0:
		return
	
	_scan_times.set(group, Time.get_ticks_msec())
	
	return acquire_random_target(group, scan_range)
