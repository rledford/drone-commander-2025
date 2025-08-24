extends Drone

@export var scrap_state: ScrapState
@onready var dropzone: Area2D = $Dropzone

@export var max_scrap: int = 3

var total_scrap: int = 0
var pickup_target: Node
var dropoff_target: Node



func _ready() -> void:
	EventBus.scrap_pickup_requested.connect(_on_scrap_pickup_requested)
	dropzone.body_entered.connect(_on_dropzone_body_entered)


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			_update_idle(delta)
		State.PATROL:
			_update_patrol(delta)
		State.GATHER:
			_update_gather(delta)
		State.DROPOFF:
			_update_dropoff(delta)
	
	move_and_slide()

func set_state(new_state: State) -> void:
	super.set_state(new_state)
	
	if new_state == State.DROPOFF:
		dropoff_target = acquire_target_in_range(PLAYER)
	elif new_state == State.PATROL:
		plan_patrol_destination()


func _scan_for_pickups() -> void:
	pickup_target = scan_for_target(SCRAP)


func _update_idle(delta: float) -> void:
	drift(delta)
	
	if has_pickup_capacity():
		_scan_for_pickups()
		if is_valid_target(pickup_target):
			set_state(State.GATHER)
			return
	
	if can_drop_off():
		set_state(State.DROPOFF)
		return
	
	if velocity.is_zero_approx():
		set_state(State.PATROL)
		return


func _update_patrol(delta: float) -> void:
	if not is_valid_target(commander):
		set_state(State.IDLE)
	
	move_toward_target_position(patrol_destination, delta)
	
	if has_pickup_capacity():
		_scan_for_pickups()
		if is_valid_target(pickup_target):
			set_state(State.GATHER)
			return
	
	if has_arrived_at_position(patrol_destination):
		set_state(State.IDLE)
		return


func _update_gather(delta: float) -> void:
	if not is_valid_target(pickup_target):
		set_state(State.IDLE)
	
	move_toward_target_node(pickup_target, delta)
	
	if must_drop_off():
		set_state(State.DROPOFF)


func has_pickup_capacity() -> bool:
	return total_scrap < max_scrap


func can_drop_off() -> bool:
	return total_scrap > 0


func must_drop_off() -> bool:
	return total_scrap >= max_scrap


func _update_dropoff(delta: float) -> void:
	if not is_valid_target(dropoff_target):
		set_state(State.IDLE)
	
	move_toward_target_node(dropoff_target, delta)


func _on_scrap_pickup_requested(by: Node, scrap: Node, amount: int) -> void:
	if by != self: return
	if total_scrap + amount > max_scrap: return
	
	total_scrap += amount

	EventBus.scrap_gathered.emit(self, scrap)
	
	if total_scrap == max_scrap:
		set_state(State.DROPOFF)


func _on_dropzone_body_entered(_by: Node) -> void:
	if not total_scrap: return
	
	scrap_state.collect(total_scrap)
	
	total_scrap = 0
	
	set_state(State.IDLE)


func _draw():
	# draw_circle(Vector2.ZERO, scan_range, Color.BLUE, false, 0.5, true)
	pass
