extends Drone

@export var attack_distance_tolerance: float = 32.0
@export var fire_rate: float = 0.5
@export var bullet_speed: float = 512.0
@export var bullet_damage: int = 50

@onready var attack_range: float = scan_range + attack_distance_tolerance * 0.5

var attack_target: Node
var keep_in_range_position: Vector2

var _last_fire_time: float = -INF


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			_update_idle(delta)
		State.PATROL:
			_update_patrol(delta)
		State.ATTACK:
			_update_attack(delta)
	
	move_and_slide()


func set_state(new_state: State) -> void:
	super.set_state(new_state)
	
	match new_state:
		State.IDLE:
			attack_target = null
			patrol_target = null
		State.PATROL:
			patrol_target = acquire_target_in_range(PLAYER)
			plan_patrol_destination()
		State.ATTACK:
			pass


func fire() -> void:
	self._last_fire_time = Time.get_ticks_msec()

	var dir = global_position.direction_to(attack_target.global_position)
	EventBus.bullet_fired.emit(Vector2(position), dir, bullet_speed, bullet_damage)


func can_fire() -> bool:
	return _last_fire_time + fire_rate * 1000.0 < Time.get_ticks_msec()


func _update_idle(delta: float) -> void:
	drift(delta)
	
	if velocity.is_zero_approx():
		set_state(State.PATROL)
		return


func _update_patrol(delta: float) -> void:
	if not is_valid_target(patrol_target):
		set_state(State.IDLE)
	
	move_toward_target_position(patrol_destination, delta)
	
	_scan_for_attack_target()
	
	if is_valid_target(attack_target):
		set_state(State.ATTACK)
		return
	
	if has_arrived_at_position(patrol_destination):
		set_state(State.IDLE)
		return


func _update_attack(delta: float) -> void:
	if not is_valid_target(attack_target):
		set_state(State.IDLE)
		return
	
	keep_target_at_distance(attack_target, scan_range, attack_distance_tolerance, delta)
	
	if not is_in_range(attack_target, attack_range) or not can_fire(): return
	
	fire()


func _scan_for_attack_target() -> void:
	attack_target = scan_for_target(ENEMY)
	
