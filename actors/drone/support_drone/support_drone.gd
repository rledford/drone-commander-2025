@tool
extends Drone

@export var heal_rate: float = 3.0
@export var base_heal_amount: int = 30
@export var aoe_radius: float = 192.0:
	set(value):
		aoe_radius = value
		_update_aoe_area()

@onready var aoe: Area2D = $AoE
@onready var aoe_shape_2d: CollisionShape2D = $AoE/CollisionShape2D

var target: Node
var supported_nodes: Array[Node] = []
var _last_heal_time = -INF


func _ready() -> void:
	aoe.body_entered.connect(_handle_aoe_body_entered)
	aoe.body_exited.connect(_handle_aoe_body_exited)
	EventBus.unit_healed.connect(_handle_unit_healed)


func _handle_aoe_body_entered(node: Node) ->void:
	supported_nodes.append(node)


func _handle_aoe_body_exited(node: Node) -> void:
	var index = supported_nodes.find(node)
	
	if index >= 0:
		supported_nodes.remove_at(index)


func _handle_unit_healed(_by: Node, on: Node, amount: int) -> void:
	if on != self: return
	
	hp = clamp(hp + amount, 0, max_hp)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	match state:
		State.IDLE:
			_update_idle(delta)
		State.FOLLOW:
			_update_follow(delta)
	
	heal_supported_nodes()
	move_and_slide()


func heal_supported_nodes() -> void:
	if not can_heal(): return
	
	_last_heal_time = Time.get_ticks_msec()
	
	for node in supported_nodes:
		EventBus.unit_healed.emit(self, node, base_heal_amount)
	
	if hp < max_hp:
		EventBus.unit_healed.emit(self, self, base_heal_amount)


func can_heal() -> bool:
	if _last_heal_time + heal_rate * 1000.0 > Time.get_ticks_msec():
		return false
	
	if len(supported_nodes) == 0 and hp >= max_hp:
		return false
	
	return true


func _update_idle(delta: float) -> void:
	drift(delta)
	target = scan_for_target(PLAYER)
	
	if is_valid_target(target):
		set_state(State.FOLLOW)


func _update_follow(delta: float) -> void:
	if not is_valid_target(target):
		set_state(State.IDLE)
		return
	
	if is_in_range(target, aoe_radius):
		var target_speed = target.get("max_speed")
		speed_scale = target_speed / max_speed if target_speed else 1.0
		drift(delta)
	else:
		speed_scale = 1.0
	
	keep_target_in_range(target, aoe_radius * 0.85, delta)

func _draw() -> void:
	draw_circle(Vector2.ZERO, aoe_radius, Color.GREEN, false)


func _update_aoe_area() -> void:
	var shape: CircleShape2D = aoe_shape_2d.shape
	shape.radius = aoe_radius
