extends Node2D

@onready var collectible: CollectibleComponent = $CollectibleComponent

func _ready() -> void:
	collectible.collected.connect(_on_collected)


func _on_collected(by: Node, item_id: String, amount: int) -> void:
	print("collected ", item_id, " x", amount, " by ", by.name)
	queue_free()
