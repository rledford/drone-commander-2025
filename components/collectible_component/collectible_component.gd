extends Node
class_name CollectibleComponent

signal collected(by: Node, item_id: String, amount: int)

@export var item_id: StringName
@export var amount: int = 1
@export var area: Area2D


func _ready() -> void:
	if not area: return
	
	area.body_entered.connect(_handle_body_entered)
	area.body_exited.connect(_handle_body_exited)


func _handle_body_entered(node: Node) -> void:
	collected.emit(node, item_id, amount)


func _handle_body_exited(_node: Node) -> void:
	pass
