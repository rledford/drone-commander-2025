@tool
extends Area2D
class_name AreaOfEffectComponent

@export var radius: float = 1.0:
	set(value):
		radius = value
		_update_radius()
		

var nodes_in_area: Array[Node] = []
var collision_shape: CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	child_entered_tree.connect(_update_radius)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return


func _on_body_entered(node: Node) -> void:
	nodes_in_area.append(node)


func _on_body_exited(node: Node) -> void:
	nodes_in_area.erase(node)


func _update_radius() -> void:
	collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape:
		(collision_shape.shape as CircleShape2D).radius = radius


func _on_child_entered_tree(_node: Node) -> void:
	_update_radius()
