@tool
extends Drone

const IDLE_STATE = &"idle"
const FOLLOW_STATE = &"follow"

@export var heal_rate: float = 3.0
@export var base_heal_amount: int = 30

@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var aoe_component: AreaOfEffectComponent = $AreaOfEffectComponent
@onready var proximity_component: ProximityComponent = $ProximityComponent

var target: Node
var state_machine: CallableStateMachine
var _last_heal_time = -INF


func _ready() -> void:
	EventBus.unit_healed.connect(_handle_unit_healed)
	
	state_machine = CallableStateMachine.new()
	state_machine.add_state(IDLE_STATE, Callable(), _update_idle, Callable())
	state_machine.add_state(FOLLOW_STATE, Callable(), _update_follow, Callable())
	state_machine.change_state(IDLE_STATE)


func _handle_unit_healed(_by: Node, on: Node, amount: int) -> void:
	if on != self: return
	
	health_component.heal(amount)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	state_machine.update(delta)
	velocity_component.move(self)


func _heal() -> void:
	if not can_heal(): return
	
	_last_heal_time = Time.get_ticks_msec()
	
	for node in aoe_component.nodes_in_area:
		EventBus.unit_healed.emit(self, node, base_heal_amount)
	
	if hp < max_hp:
		EventBus.unit_healed.emit(self, self, base_heal_amount)


func can_heal() -> bool:
	if _last_heal_time + heal_rate * 1000.0 > Time.get_ticks_msec():
		return false
	
	if len(aoe_component.nodes_in_area) == 0 and hp >= max_hp:
		return false
	
	return true


func _update_idle(delta: float) -> void:
	_heal()
	
	movement_component.drift()
	target = proximity_component.acquire_closest_target(PLAYER, INF)
	
	if is_valid_target(target):
		return state_machine.change_state(FOLLOW_STATE)


func _update_follow(delta: float) -> void:
	_heal()
	
	if not is_valid_target(target):
		return state_machine.change_state(IDLE_STATE)
	
	movement_component.keep_range_node(target, aoe_component.radius * 0.85)


func _draw() -> void:
	draw_circle(Vector2.ZERO, aoe_component.radius, Color.GREEN, false)
