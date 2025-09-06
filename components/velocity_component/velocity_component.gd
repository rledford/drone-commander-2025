extends Node
class_name VelocityComponent

@export var max_speed: float = 100.0
@export var acceleration_coefficient: float = 10.0

var velocity: Vector2 = Vector2.ZERO


func move(char_body: CharacterBody2D) -> void:
	char_body.velocity = velocity
	char_body.move_and_slide()


func decelerate() -> void:
	accelerate_to_velocity(Vector2.ZERO)


func accelerate_to_velocity(target_velocity: Vector2) -> void:
	velocity = velocity.lerp(target_velocity, 1.0 - exp(
			-acceleration_coefficient * get_process_delta_time()
		)
	)

func get_max_velocity(direction: Vector2) -> Vector2:
	return direction * max_speed
