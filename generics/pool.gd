extends RefCounted
class_name Pool

var scene: PackedScene
var free: Array[Node] = []

func _init(packed: PackedScene, prewarm: int = 0):
	scene = packed
	for i in prewarm:
		free.append(scene.instantiate())


func acquire() -> Node:
	var node := free.pop_back() if not free.is_empty() else scene.instantiate() as Node
	node.set_meta(&"pool", self)
	return node


func release(node: Node) -> void:
	if not is_instance_valid(node):
		return
	var parent := node.get_parent()
	if parent:
		parent.call_deferred("remove_child", node)
	free.push_back(node)
