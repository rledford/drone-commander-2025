extends Node
class_name InteractableComponent

signal focused
signal unfocused
signal interact

@export var area: Area2D

var _focused: bool = false


func _ready() -> void:
	if not area: return
	
	area.body_entered.connect(_handle_body_entered)
	area.body_exited.connect(_handle_body_exited)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and _focused:
		interact.emit()


func _handle_body_entered(_body: Node2D) -> void:
	focused.emit()
	_focused = true


func _handle_body_exited(_body: Node2D) -> void:
	unfocused.emit()
	_focused = false
