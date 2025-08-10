extends Node
class_name PoolManager

var pools: Dictionary = {} # StringName -> Pool

func register_pool(key: StringName, scene: PackedScene, prewarm: int = 0) -> void:
	pools[key] = Pool.new(scene, prewarm)


func get_pool(key: StringName) -> Pool:
	return pools.get(key)


func acquire(key: StringName) -> Node:
	var p: Pool = pools.get(key)
	assert(p != null, "Pool not registered: %s" % key)
	return p.acquire()


func release(node: Node) -> void:
	var p: Pool = node.get_meta(&"pool", null)
	if p:
		p.release(node)
