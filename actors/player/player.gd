extends CharacterBody2D

@export var scrap_state: ScrapState
@export var arsenal: ArsenalState

@export var fire_rate: float = 0.5
@export var bullet_speed: float = 600.0
@export var bullet_damage: int = 25

var _last_fire_time = -INF

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	arsenal.commander = self
	EventBus.scrap_pickup_requested.connect(_on_scrap_pickup_requested)
	EventBus.unit_healed.connect(_on_unit_healed)
	
	health_component.depleted.connect(_on_health_depleted)
	


func _process(_delta: float) -> void:
	if health_component.is_depleted():
		return
	
	if Input.is_action_pressed("shoot"):
		self.shoot()


func shoot():
	var now = Time.get_ticks_msec()
	
	if _last_fire_time + fire_rate * 1000.0 > now:
		return
	
	self._last_fire_time = now

	var dir = self.global_position.direction_to(get_global_mouse_position())
	EventBus.bullet_fired.emit(Vector2(position), dir, bullet_speed, bullet_damage)


func _physics_process(_delta: float) -> void:
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	_aim()
	velocity_component.accelerate_to_velocity(
		velocity_component.get_max_velocity(input_dir)
	)
	velocity_component.move(self)


func _aim() -> void:
	look_at(get_global_mouse_position())


func _on_scrap_pickup_requested(by: Node, scrap: Node, amount: int) -> void:
	if by != self: return
	
	EventBus.scrap_gathered.emit(self, scrap)
	scrap_state.collect(amount)


func _on_health_depleted() -> void:
	pass


func _on_unit_healed(_by: Node, target: Node, amount: int) -> void:
	if target != self: return
	
	health_component.heal(amount)
