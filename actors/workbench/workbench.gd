extends Node2D

@onready var interaction: InteractableComponent = $InteractableComponent

func _ready() -> void:
	interaction.interact.connect(_on_interact)


func _on_interact():
	print("interacted with workbench")
