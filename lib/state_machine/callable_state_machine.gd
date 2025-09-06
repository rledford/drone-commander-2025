extends RefCounted
class_name CallableStateMachine

var _states = {}
var _current_state: Dictionary

func add_state(
	key: StringName,
	on_enter: Callable,
	on_update: Callable,
	on_exit: Callable):
	_states.set(
		key,
		{
			"on_enter": on_enter,
			"on_update": on_update,
			"on_exit": on_exit
		}
	)


func change_state(to: StringName) -> void:
	assert(_states.has(to), "State [ %s ] not registered" % to)
	# print("changing state to %s " % to)

	if _current_state and _current_state.on_exit:
		_current_state.on_exit.call()
	
	_current_state = _states.get(to)
	
	if _current_state.on_enter:
		_current_state.on_enter.call()


func update(delta: float) -> void:
	if not _current_state: return
	
	_current_state.on_update.call(delta)
