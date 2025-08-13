extends CharacterBody2D

@export var carry_capacity: int = 3
@onready var dropzone: Area2D = $Dropzone

var _carry_count: int = 0
var _scrap_target: Node2D


func _ready() -> void:
	EventBus.scrap_collect_requested.connect(_on_scrap_collect_requested)
	dropzone.body_entered.connect(_on_dropzone_body_entered)


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_scrap_collect_requested(by: Node, scrap: Node, amount: int) -> void:
	if by != self: return
	if _carry_count + amount > carry_capacity: return
	
	_carry_count += amount
	print('gathered scrap')


func _on_dropzone_body_entered(by: Node) -> void:
	if not _carry_count: return
	
	EventBus.scrap_delivered.emit(self, by, _carry_count)
	
	_carry_count = 0
