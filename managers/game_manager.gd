extends Node
class_name GameManager

const BulletScene = preload('res://actors/bullet/bullet.tscn')

var _bullet_pool: Array[Bullet] = []
var _bullet_pool_size: int = 10

func _ready() -> void:
	EventBus.bullet_expired.connect(return_bullet)
	
	for i in _bullet_pool_size:
		return_bullet(BulletScene.instantiate())


func get_bullet() -> Bullet:
	if _bullet_pool.is_empty():
		var new_bullet = BulletScene.instantiate()
		add_child(new_bullet)
		return new_bullet
	else:
		var bullet: Bullet = _bullet_pool.pop_back()
		_activate(bullet)
		add_child(bullet)
		return bullet


func return_bullet(bullet: Bullet) -> void:
	_deactivate(bullet)
	_bullet_pool.append(bullet)


func _activate(node: Node2D):
	node.set_process(true)
	node.set_physics_process(true)
	node.visible = true
	print("pool size ", len(_bullet_pool))


func _deactivate(node: Node2D):
	node.set_process(false)
	node.set_physics_process(false)
	node.visible = false
