extends Node
class_name GameManager

@export var pool_manager: PoolManager
@export var bullet_container: Node

func _ready() -> void:
	EventBus.item_collected.connect(on_item_collected)
	EventBus.bullet_fired.connect(on_bullet_fired)
	EventBus.bullet_expired.connect(on_bullet_expired)
	
	pool_manager.register_pool(
		&"bullet",
		preload("res://actors/bullet/bullet.tscn"),
		100
	)


func on_item_collected(by: Node, item_id: String, amount: int) -> void:
	print("Item ", item_id, " x", amount, " collected by ", by.name)


func on_bullet_fired(team_id: String, position: Vector2, direction: Vector2, speed: float, damage: int) -> void:
	print("bullet fired by team %s from %s toward %s moving %s px/s for %s damage" % [team_id, position, direction, speed, damage])
	
	var bullet = (pool_manager.acquire(&"bullet") as Bullet)
	bullet.setup(position, direction, speed, damage)
	
	bullet_container.add_child(bullet)



func on_bullet_expired(bullet: Node) -> void:
	print("bullet expired")
	if not is_instance_of(bullet, Bullet): return
	bullet.position = Vector2.ZERO
	bullet.direction = Vector2.ZERO
	bullet.speed = 0.0
	bullet.damage = 0.0

	pool_manager.get_pool(&"bullet").release(bullet)
	
