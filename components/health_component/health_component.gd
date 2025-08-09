extends Node
class_name HealthComponent

@export var health: int = 1
@export var max_health: int = 1

signal health_changed(new_health: int, old_health: int)
signal max_health_changed(new_max_health: int, old_max_health: int)
signal health_depleted

func _ready() -> void:
	health = max_health


func take_damage(amount: int) -> void:
	if amount < 0: return
	
	var old_health = health
	health = clamp(health - amount, 0, max_health)
	health_changed.emit(health, old_health)

	if health == 0:
		health_depleted.emit()


func heal(amount: int) -> void:
	if amount < 0: return
	
	var old_health = health
	health = clamp(health + amount, 0, max_health)
	health_changed.emit(health, old_health)


func set_max_health(new_max: int) -> void:
	if new_max < 1: return
	
	var old_max_health = health
	max_health = new_max
	max_health_changed.emit(max_health, old_max_health)
