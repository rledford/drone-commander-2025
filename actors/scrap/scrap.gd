extends CharacterBody2D
class_name Scrap

@onready var collectible: CollectibleComponent = $CollectibleComponent

var slide_speed: float = 25.0
var slide_decay: float = 10.0
var slide_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	collectible.collected.connect(_on_collected)


func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, delta * slide_decay)
	move_and_slide()


func setup(pos: Vector2):
	var rand_angle = randf() * 2.0 * PI
	slide_direction = Vector2.RIGHT.rotated(rand_angle)
	velocity = slide_direction * slide_speed
	global_position = pos


func _on_collected(by: Node, _item_id: String, amount: int) -> void:
	EventBus.scrap_pickup_requested.emit(by, self, amount)
