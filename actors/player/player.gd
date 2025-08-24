extends CharacterBody2D

@export var scrap_state: ScrapState
@export var arsenal: ArsenalState

@export var max_hp: int = 100
@export var max_speed: float = 100.0
@export var accel: float = 640.0
@export var decel: float = 320.0
@export var fire_rate: float = 0.5
@export var bullet_speed: float = 600.0
@export var bullet_damage: int = 25

@onready var hp: int = max_hp

var _last_fire_time = -INF


func _ready() -> void:
	arsenal.commander = self
	EventBus.scrap_pickup_requested.connect(_on_scrap_pickup_requested)
	EventBus.unit_healed.connect(_on_unit_healed)
	
	hp = 1


func _process(_delta: float) -> void:
	if hp <= 0:
		EventBus.player_dead.emit()
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


func _physics_process(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	velocity.x = move_toward(
		velocity.x, input_dir.x * max_speed,
		delta * (accel if input_dir.x != 0 else decel)
	)

	velocity.y = move_toward(
		velocity.y, input_dir.y * max_speed,
		delta * (accel if input_dir.y != 0 else decel)
	)
	
	_aim()
	
	move_and_slide()


func _aim() -> void:
	# self.rotation = self.global_position.angle_to(get_global_mouse_position())
	look_at(get_global_mouse_position())


func _on_scrap_pickup_requested(by: Node, scrap: Node, amount: int) -> void:
	if by != self: return
	
	EventBus.scrap_gathered.emit(self, scrap)
	scrap_state.collect(amount)


func _on_unit_healed(_by: Node, target: Node, amount: int) -> void:
	if target != self or hp >= max_hp: return
	
	var old_hp = hp
	hp = clamp(hp + amount, 0, max_hp)
	
	print('player hp %s healed for %s resulting in new hp %s' % [old_hp, amount, hp])
