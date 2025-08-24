extends CharacterBody2D

@export var max_hp: int = 50
@onready var hp = max_hp

func _ready() -> void:
	EventBus.bullet_collided.connect(_handle_bullet_collided)


func _handle_bullet_collided(with: Node, _vel: Vector2, damage: int) -> void:
	if with != self: return
	
	hp -= damage
	
	if hp <= 0:
		drop_scrap()
		queue_free()


func drop_scrap() -> void:
	for i in randi_range(2,3):
		EventBus.scrap_dropped.emit(global_position)
