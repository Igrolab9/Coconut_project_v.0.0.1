extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Сообщаем MusicManager что сцена загрузилась
	if MusicManager:
		MusicManager._play_current_track()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
