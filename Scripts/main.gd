extends Node3D

@onready var start_game_button: Button = $CanvasLayer/StartButton

func _ready() -> void:
	# ВАЖНО: устанавливаем режим обработки ДО паузы
	start_game_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if MusicManager:
		MusicManager._play_current_track()
		
	start_game_button.pressed.connect(_on_start_game_pressed)
	get_tree().paused = true

func _on_start_game_pressed() -> void:
	get_tree().paused = false
	start_game_button.queue_free()
