extends Node2D

@export var scrap_store: ScrapState

@export var DroneScene: PackedScene

@export var craft_type: StringName
@export var craft_time: float
@export var craft_cost: int = 10

@onready var interaction: InteractableComponent = $InteractableComponent

signal craft_progress_changed(new_progress: float, old_progress: float)

var _is_crafting = false
var _craft_progress = 0.0


func _ready() -> void:
	interaction.interact.connect(_on_interact)


func _process(delta: float) -> void:
	if _is_crafting:
		var old_craft_progress = _craft_progress
		_craft_progress = clamp(_craft_progress + delta, 0.0, craft_time)
		craft_progress_changed.emit(_craft_progress, old_craft_progress)
		if _craft_progress >= craft_time:
			_complete_crafting()


func _start_crafting():
	print("crafting %s..." % [craft_type])
	_is_crafting = true
	_craft_progress = 0.0


func _complete_crafting():
	print("crafted %s" % [craft_type])
	_is_crafting = false
	var drone = DroneScene.instantiate()
	EventBus.drone_created.emit(self, drone)


func _on_interact():
	if _is_crafting: return
	
	if scrap_store.scrap < craft_cost:
		print("not enough in store")
	else:
		scrap_store.scrap -= craft_cost
		_start_crafting()
