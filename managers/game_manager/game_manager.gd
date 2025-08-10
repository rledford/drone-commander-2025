extends Node
class_name GameManager

@onready var bullet_pool: Node = $BulletPool

func _ready() -> void:
	EventBus.item_collected.connect(handle_item_collected)


func handle_item_collected(by: Node, item_id: String, amount: int) -> void:
	print("Item ", item_id, " x", amount, " collected by ", by.name)
