# CoconutHealth.gd
extends RefCounted
class_name CoconutHealth  # ← ЭТУ СТРОКУ НУЖНО ДОБАВИТЬ

signal broken

var _is_broken: bool = false

func is_broken() -> bool:
	return _is_broken

func take_damage() -> void:
	if _is_broken:
		return
	_is_broken = true
	broken.emit()
