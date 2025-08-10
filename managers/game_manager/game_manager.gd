extends Node
class_name GameManager

@export var pool_manager: PoolManager

func _ready() -> void:
	EventBus.item_collected.connect(handle_item_collected)
	
	pool_manager.register_pool(
		&"bullet",
		preload("res://actors/bullet/bullet.tscn"),
		100
	)


func handle_item_collected(by: Node, item_id: String, amount: int) -> void:
	print("Item ", item_id, " x", amount, " collected by ", by.name)
