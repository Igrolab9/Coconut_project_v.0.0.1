extends CanvasLayer

@onready var _start_button: Button = $StartButton
@onready var _authors_button: Button = $AuthorsButton
# ⭐ Ссылка на Label, который мы создадим в сцене
@onready var _high_score_label: Label = $HighScoreLabel 

const MAIN_LEVEL: String = "res://Scenes/main.tscn"
const AUTHOR_SCENE: String = "res://Scenes/authors_scene.tscn"
const SAVE_PATH = "user://highscore.cfg"

func _ready() -> void:
	_start_button.pressed.connect(_on_start_game_pressed)
	_authors_button.pressed.connect(_on_authors_button_pressed)
	_update_high_score_display() # ⭐ Загружаем и показываем рекорд при старте

func _update_high_score_display() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	var high_score = 0
	
	if err == OK:
		high_score = config.get_value("game", "high_score", 0)
	
	if _high_score_label:
		_high_score_label.text = "🏆 Рекорд: " + str(high_score)
		# Стилизация под стиль вашей игры (как в coconut_player.gd)
		_high_score_label.add_theme_font_size_override("font_size", 36)
		_high_score_label.add_theme_color_override("font_color", Color.GOLD)
		_high_score_label.add_theme_color_override("font_outline_color", Color.BLACK)
		_high_score_label.add_theme_constant_override("outline_size", 6)
	else:
		push_warning("MainMenu: Узел HighScoreLabel не найден! Проверьте имя узла в сцене.")

func _on_start_game_pressed() -> void:
	_change_scene(MAIN_LEVEL)
	
func _on_authors_button_pressed() -> void:
	_change_scene(AUTHOR_SCENE)

func _change_scene(scene_path: String) -> void:
	if not FileAccess.file_exists(scene_path):
		push_error("MainMenu: файл сцены не найден — %s" % scene_path)
		return
	var error: int = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("MainMenu: ошибка смены сцены, код %d" % error)
