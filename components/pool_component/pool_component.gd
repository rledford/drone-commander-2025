extends Node

@export var _entity: PackedScene
@export var _size: int = 1

var _pool: Array[Node] = []

func init(entity: PackedScene, size: int = 1) -> void:
	_entity = entity
	_size = size

func _ready() -> void:
	for i in _size:
		_pool.append(_entity.instantiate())

func acquire() -> Node:
	if _pool.is_empty():
		var new_entity = _entity.instantiate()
		add_child(new_entity)
		
		return new_entity
	else:
		var entity: Node = _pool.pop_back()
		_activate(entity)
		
		return entity


func release(node: Node) -> void:
	_deactivate(node)
	_pool.append(node)


func _activate(node: Node2D):
	node.set_process(true)
	node.set_physics_process(true)
	node.visible = true


func _deactivate(node: Node2D):
	node.set_process(false)
	node.set_physics_process(false)
	node.visible = false
