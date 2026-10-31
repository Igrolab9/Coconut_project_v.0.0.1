extends CanvasLayer

@onready var _back_button: Button = $BackButton
const MAIN_MENU_SCENE: String = "res://Scenes/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	_change_scene(MAIN_MENU_SCENE)

func _change_scene(scene_path: String) -> void:
	# ✅ ИСПОЛЬЗУЕМ ResourceLoader.exists вместо FileAccess.file_exists
	# Он корректно понимает, что в экспорте .tscn превращается в .scn
	if not ResourceLoader.exists(scene_path):
		push_error("MainMenu: ресурс сцены не найден — %s" % scene_path)
		return
	
	# ✅ Безопасная смена сцены (как мы обсуждали ранее, через call_deferred)
	get_tree().call_deferred("change_scene_to_file", scene_path)
