extends Node2D

@export var craft_type: StringName
@export var craft_time: float
@export var craft_cost: int = 10

@onready var interaction: InteractableComponent = $InteractableComponent

signal craft_progress_changed(new_progress: float, old_progress: float)

var _is_crafting = false
var _craft_progress = 0.0


func _ready() -> void:
	interaction.interact.connect(_on_interact)
	EventBus.craft_drone_request_accepted.connect(_on_craft_request_accepted)
	EventBus.craft_drone_request_rejected.connect(_on_craft_request_rejected)


func _process(delta: float) -> void:
	if _is_crafting:
		var old_craft_progress = _craft_progress
		_craft_progress = clamp(_craft_progress + delta, 0.0, craft_time)
		craft_progress_changed.emit(_craft_progress, old_craft_progress)
		if _craft_progress >= craft_time:
			_complete_crafting()

func _on_craft_request_accepted(to: Node) -> void:
	if not to == self: return
	
	_start_crafting()


func _on_craft_request_rejected(to: Node, reason: String) -> void:
	print("checking rejected craft request")
	if not to == self: return
	
	print("Unable to craft %s: %s" % [self.craft_type, reason])


func _start_crafting():
	print("crafting %s..." % [craft_type])
	_is_crafting = true
	_craft_progress = 0.0


func _complete_crafting():
	print("crafted %s" % [craft_type])
	_is_crafting = false
	# emit whatever to spawn drone at some position


func _on_interact():
	if _is_crafting: return
	
	EventBus.craft_drone_requested.emit(self, craft_cost)
