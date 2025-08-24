extends Resource
class_name ScrapState

signal collected(amount: int)
signal scrap_updated(from: int, to: int)

var scrap: int = 10:
	set = _set_scrap


func collect(amount: int = 0) -> void:
	_set_scrap(scrap + amount)
	collected.emit(amount)


func _set_scrap(to: int) -> void:
	var prev: int = scrap
	scrap = to
	scrap_updated.emit(prev, to)
	print("new scrap amount %s" % scrap)
