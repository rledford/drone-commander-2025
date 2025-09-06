extends Drone

const IDLE_STATE = &"idle"
const PATROL_STATE = &"patrol"
const ATTACK_STATE = &"attack"

@export var attack_distance_tolerance: float = 32.0
@export var fire_rate: float = 0.5
@export var bullet_speed: float = 512.0
@export var bullet_damage: int = 50

@onready var attack_range: float = scan_range + attack_distance_tolerance * 0.5

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var patrol_component: PatrolComponent = $PatrolComponent
@onready var proximity_component: ProximityComponent = $ProximityComponent

var attack_target: Node
var keep_in_range_position: Vector2
var state_machine: CallableStateMachine

var _last_fire_time: float = -INF


func _ready() -> void:
	state_machine = CallableStateMachine.new()
	state_machine.add_state(IDLE_STATE, _on_enter_idle, _update_idle, Callable())
	state_machine.add_state(PATROL_STATE, _on_enter_patrol, _update_patrol, Callable())
	state_machine.add_state(ATTACK_STATE, Callable(), _update_attack, Callable())
	state_machine.change_state(IDLE_STATE)


func _physics_process(delta: float) -> void:
	state_machine.update(delta)
	velocity_component.move(self)


func _on_enter_idle() -> void:
	attack_target = null


func _on_enter_patrol() -> void:
	patrol_component.target_node = commander


func fire() -> void:
	self._last_fire_time = Time.get_ticks_msec()

	var dir = global_position.direction_to(attack_target.global_position)
	EventBus.bullet_fired.emit(Vector2(position), dir, bullet_speed, bullet_damage)


func can_fire() -> bool:
	return _last_fire_time + fire_rate * 1000.0 < Time.get_ticks_msec()


func _update_idle(_delta: float) -> void:
	movement_component.drift()
	
	if is_valid_target(commander):
		return state_machine.change_state(PATROL_STATE)


func _update_patrol(delta: float) -> void:
	if not is_valid_target(commander):
		return state_machine.change_state(IDLE_STATE)
		
	patrol_component.update(delta)
	
	_scan_for_attack_target()
	
	if is_valid_target(attack_target):
		return state_machine.change_state(ATTACK_STATE)
	
	if has_arrived_at_position(patrol_destination):
		return state_machine.change_state(IDLE_STATE)


func _update_attack(_delta: float) -> void:
	if not is_valid_target(attack_target):
		return state_machine.change_state(IDLE_STATE)
	
	movement_component.keep_range_node(attack_target, attack_range, attack_distance_tolerance)
	
	if not proximity_component.is_in_range(attack_target, attack_range) or not can_fire(): return
	
	fire()


func _scan_for_attack_target() -> void:
	attack_target = proximity_component.scan_for_target(ENEMY)
	
