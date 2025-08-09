extends Node2D
class_name Bullet

const max_lifetime = 5.0

var direction: Vector2 = Vector2.RIGHT
var speed: float = 100.0
var damage: int = 1
var lifetime: float = max_lifetime


func init(pos: Vector2, dir: Vector2, spd: float, dmg: int) -> void:
	position = pos
	direction = dir
	speed = spd
	damage = dmg
	lifetime = max_lifetime


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		EventBus.bullet_expired.emit(self)
