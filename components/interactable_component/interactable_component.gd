@tool
extends Node2D
class_name InteractableComponent

@onready var area: Area2D = $Area2D
@onready var area_collider: CollisionShape2D = $Area2D/CollisionShape2D

@export var area_width: float = 16.0:
	set(value):
		area_width = value
		_update_area_shape()
@export var area_height: float = 16.0:
	set(value):
		area_height = value
		_update_area_shape()

var _focused: bool = false

signal focused
signal unfocused
signal interact

func _ready() -> void:
	area.body_entered.connect(_handle_body_entered)
	area.body_exited.connect(_handle_body_exited)
	_update_area_shape()
	


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_area_shape()
		return
	
	if Input.is_action_just_pressed("interact") and _focused:
		interact.emit()


func _handle_body_entered(body: Node2D) -> void:
	focused.emit()
	_focused = true


func _handle_body_exited(body: Node2D) -> void:
	unfocused.emit()
	_focused = false


func _set_area_width(value: float) -> void:
	var size = (area_collider.shape as RectangleShape2D).size
	(area_collider.shape as RectangleShape2D).size = Vector2(value, size.y)
	area_width = value


func _set_area_height(value: float) -> void:
	var size = (area_collider.shape as RectangleShape2D).size
	(area_collider.shape as RectangleShape2D).size = Vector2(size.x, value)
	area_height = value


func _update_area_shape() -> void:
	if not area_collider: return
	
	(area_collider.shape as RectangleShape2D).size = Vector2(area_width, area_height)
