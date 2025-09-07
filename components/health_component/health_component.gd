extends Node
class_name HealthComponent

@export var max_hp: int = 1

var hp: int = 0

signal changed(new_hp: int, old_hp: int)
signal max_changed(new_max_hp: int, old_max_hp: int)
signal depleted

func _ready() -> void:
	hp = max_hp


func is_depleted() -> bool:
	return hp <= 0


func is_damaged() -> bool:
	return hp > 0 and hp < max_hp

func take_damage(amount: int) -> void:
	if amount < 0: return
	
	var old_hp = hp
	hp = clamp(hp - amount, 0, max_hp)
	changed.emit(hp, old_hp)

	if hp == 0:
		depleted.emit()


func heal(amount: int) -> void:
	if amount <= 0 or hp >= max_hp: return
	
	var old_hp = hp
	hp = clamp(hp + amount, 0, max_hp)
	changed.emit(hp, old_hp)


func set_max(new_max: int) -> void:
	if new_max < 1: return
	
	var old_max_hp = hp
	max_hp = new_max
	max_changed.emit(max_hp, old_max_hp)
