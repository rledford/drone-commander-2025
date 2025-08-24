extends Node2D

@export var arsenal: ArsenalState


func _ready() -> void:
	arsenal.commander = self
