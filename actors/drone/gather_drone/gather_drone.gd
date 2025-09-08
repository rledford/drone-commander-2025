extends Drone

const IDLE_STATE = &"idle"
const PATROL_STATE = &"patrol"
const GATHER_STATE = &"gather"
const DROPOFF_STATE = &"dropoff"

@export var scrap_state: ScrapState
@export var max_scrap: int = 3

@onready var dropzone: Area2D = $Dropzone
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var patrol_component: PatrolComponent = $PatrolComponent
@onready var proximity_component: ProximityComponent = $ProximityComponent

var total_scrap: int = 0
var pickup_target: Node
var dropoff_target: Node
var state_machine: CallableStateMachine


func _ready() -> void:
	EventBus.scrap_pickup_requested.connect(_on_scrap_pickup_requested)
	dropzone.body_entered.connect(_on_dropzone_body_entered)
	
	state_machine = CallableStateMachine.new()
	state_machine.add_state(IDLE_STATE, Callable(), _update_idle, Callable())
	state_machine.add_state(PATROL_STATE, _on_enter_patrol, _update_patrol, Callable())
	state_machine.add_state(GATHER_STATE, Callable(), _update_gather, Callable())
	state_machine.add_state(DROPOFF_STATE, _on_enter_dropoff, _update_dropoff, Callable())
	state_machine.change_state(IDLE_STATE)


func _physics_process(delta: float) -> void:
	state_machine.update(delta)
	velocity_component.move(self)


func _on_enter_dropoff() -> void:
	dropoff_target = proximity_component.acquire_closest_target(
		Constants.PLAYER_GROUP,
		INF
	)


func _on_enter_patrol() -> void:
	patrol_component.target_node = commander


func _scan_for_pickups() -> void:
	pickup_target = proximity_component.scan_for_target(Constants.SCRAP_GROUP)


func _update_idle(_delta: float) -> void:
	movement_component.drift()
	
	if has_pickup_capacity():
		_scan_for_pickups()
		if is_valid_target(pickup_target):
			return state_machine.change_state(GATHER_STATE)
	
	if can_drop_off():
		return state_machine.change_state(DROPOFF_STATE)
	
	if is_valid_target(commander):
		return state_machine.change_state(PATROL_STATE)


func _update_patrol(delta: float) -> void:
	if not is_valid_target(commander):
		return state_machine.change_state(IDLE_STATE)
		
	patrol_component.update(delta)
	
	if has_pickup_capacity():
		_scan_for_pickups()
		if is_valid_target(pickup_target):
			return state_machine.change_state(GATHER_STATE)


func _update_gather(_delta: float) -> void:
	if not is_valid_target(pickup_target):
		return state_machine.change_state(IDLE_STATE)
	
	movement_component.move_toward_node(pickup_target)
	
	if must_drop_off():
		return state_machine.change_state(DROPOFF_STATE)


func has_pickup_capacity() -> bool:
	return total_scrap < max_scrap


func can_drop_off() -> bool:
	return total_scrap > 0


func must_drop_off() -> bool:
	return total_scrap >= max_scrap


func _update_dropoff(_delta: float) -> void:
	if not is_valid_target(dropoff_target):
		return state_machine.change_state(IDLE_STATE)
	
	movement_component.move_toward_node(dropoff_target)


func _on_scrap_pickup_requested(by: Node, scrap: Node, amount: int) -> void:
	if by != self: return
	if total_scrap + amount > max_scrap: return
	
	total_scrap += amount

	EventBus.scrap_gathered.emit(self, scrap)
	
	if total_scrap == max_scrap:
		return state_machine.change_state(DROPOFF_STATE)


func _on_dropzone_body_entered(_by: Node) -> void:
	if not total_scrap: return
	
	scrap_state.collect(total_scrap)
	
	total_scrap = 0
	
	return state_machine.change_state(IDLE_STATE)


func _draw():
	# draw_circle(Vector2.ZERO, scan_range, Color.BLUE, false, 0.5, true)
	pass
