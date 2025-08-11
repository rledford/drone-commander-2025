extends Node
class_name GameManager

@export var pool_manager: PoolManager
@export var bullet_container: Node
@export var scrap_container: Node

var _total_scrap: int = 0

func _ready() -> void:
	register_pools()
	connect_signals()


func on_bullet_fired(position: Vector2, direction: Vector2, speed: float, damage: int) -> void:
	var bullet = (pool_manager.acquire(&"bullet") as Bullet)
	bullet.setup(position, direction, speed, damage)
	
	bullet_container.add_child(bullet)


func on_bullet_hit(_bullet: Node, collision: KinematicCollision2D) -> void:
	var collider := collision.get_collider() as Node2D
	if collider.is_in_group(&"enemy"):
		collider.queue_free()
		var scrap_count = randi_range(2,3)
		for _i in range(scrap_count):
			EventBus.scrap_dropped.emit(collider.global_position)
		


func on_bullet_expired(bullet: Node) -> void:
	print("bullet expired")
	if not is_instance_of(bullet, Bullet): return
	bullet.position = Vector2.ZERO
	bullet.direction = Vector2.ZERO
	bullet.speed = 0.0
	bullet.damage = 0.0

	pool_manager.get_pool(&"bullet").release(bullet)


func on_scrap_dropped(position: Vector2) -> void:
	var scrap = pool_manager.acquire(&"scrap") as Scrap
	scrap.setup(position)
	scrap_container.add_child(scrap)


func on_scrap_collected(_by: Node, scrap: Node, amount: int) -> void:
	_total_scrap += amount
	pool_manager.get_pool(&"scrap").release(scrap)


func on_craft_drone_requested(by: Node, cost: int) -> void:
	if _total_scrap < cost:
		EventBus.craft_drone_request_rejected.emit(by, "Not enough scrap")
	else:
		var old_total_scrap = _total_scrap
		_total_scrap -= cost
		EventBus.total_scrap_changed.emit(old_total_scrap, _total_scrap)
		EventBus.craft_drone_request_accepted.emit(by)


func connect_signals():
	EventBus.scrap_dropped.connect(on_scrap_dropped)
	EventBus.scrap_collected.connect(on_scrap_collected)
	EventBus.bullet_fired.connect(on_bullet_fired)
	EventBus.bullet_hit.connect(on_bullet_hit)
	EventBus.bullet_expired.connect(on_bullet_expired)
	EventBus.craft_drone_requested.connect(on_craft_drone_requested)


func register_pools():
	pool_manager.register_pool(
		&"bullet",
		preload("res://actors/bullet/bullet.tscn"),
		100
	)
	pool_manager.register_pool(
		&"scrap",
		preload("res://actors/scrap/scrap.tscn"),
		100
	)
