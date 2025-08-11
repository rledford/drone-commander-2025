extends CharacterBody2D

@export var hp: int = 100
@export var speed: float = 100.0
@export var accel: float = 640.0
@export var decel: float = 320.0
@export var fire_rate: float = 0.5
@export var bullet_speed: float = 600.0
@export var bullet_damage: int = 25

var _last_fire_time = -INF


func _ready() -> void:
	pass


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
		velocity.x, input_dir.x * speed,
		delta * (accel if input_dir.x != 0 else decel)
	)

	velocity.y = move_toward(
		velocity.y, input_dir.y * speed,
		delta * (accel if input_dir.y != 0 else decel)
	)
	
	_aim()
	
	move_and_slide()


func _aim() -> void:
	# self.rotation = self.global_position.angle_to(get_global_mouse_position())
	look_at(get_global_mouse_position())
