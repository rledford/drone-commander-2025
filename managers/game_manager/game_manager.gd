extends Node
class_name GameManager

@export var pool_manager: PoolManager
@export var bullet_container: Node
@export var scrap_container: Node
@export var drone_container: Node

@export var player_arsenal: ArsenalState
@export var station_arsenal: ArsenalState
#@export var control_point_north_arsenal: ArsenalState
#@export var control_point_west_arsenal: ArsenalState
#@export var control_point_east_arsenal: ArsenalState

func _ready() -> void:
	register_pools()
	connect_signals()


func on_bullet_fired(position: Vector2, direction: Vector2, speed: float, damage: int) -> void:
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


func on_scrap_dropped(position: Vector2) -> void:
	var scrap = pool_manager.acquire(&"scrap") as Scrap
	scrap.setup(position)
	scrap_container.add_child(scrap)


func on_scrap_gathered(_by: Node, scrap: Node) -> void:
	pool_manager.get_pool(&"scrap").release(scrap)


func on_drone_created(_by: Node, drone: Node) -> void:
	# refactor with "type" after implementing drone stats resource
	if not is_instance_of(drone, Drone):
		push_error("invalid drone created %s" % drone)
	
	match (drone as Drone).type:
		Enums.DroneType.DAMAGE:
			if not player_arsenal.has_damage_capacity():
				station_arsenal.add_damage_drone(drone)
			else:
				player_arsenal.add_damage_drone(drone)
		Enums.DroneType.GATHER:
			if not player_arsenal.has_gather_capacity():
				station_arsenal.add_gather_drone(drone)
			else:
				player_arsenal.add_gather_drone(drone)
		Enums.DroneType.SUPPORT:
			if not player_arsenal.has_support_capacity():
				station_arsenal.add_support_drone(drone)
			else:
				player_arsenal.add_support_drone(drone)
	
	drone_container.add_child(drone)


func connect_signals():
	EventBus.drone_created.connect(on_drone_created)
	EventBus.scrap_dropped.connect(on_scrap_dropped)
	EventBus.scrap_gathered.connect(on_scrap_gathered)
	EventBus.bullet_fired.connect(on_bullet_fired)
	EventBus.bullet_expired.connect(on_bullet_expired)


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
