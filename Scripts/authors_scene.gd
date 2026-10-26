extends CanvasLayer

@onready var _back_button: Button = $BackButton
const MAIN_MENU_SCENE: String = "res://Scenes/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	_change_scene(MAIN_MENU_SCENE)

func _change_scene(scene_path: String) -> void:
	if not FileAccess.file_exists(scene_path):
		push_error("MainMenu: файл сцены не найден — %s" % scene_path)
		return
	var error: int = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("MainMenu: ошибка смены сцены, код %d" % error)
