# Coconut.gd
extends CharacterBody3D

@export var SPEED: float = 1.0
@export var JUMP_VELOCITY: float = 4.0
@export var SPIN_BOOST: float = 6.0

# === Настройки сообщения о смерти ===
@export_group("Message Settings")
@export var MESSAGE_TEXT: String = "Кокос разбился!"
@export var MESSAGE_FONT_SIZE: int = 64
@export var MESSAGE_COLOR: Color = Color.RED
@export var MESSAGE_BG_COLOR: Color = Color(0, 0, 0, 0.7)
@export var MESSAGE_DELAY: float = 3.0

# === Настройки счётчика монет ===
@export_group("Coin Counter Settings")
@export var COIN_FONT_SIZE: int = 36
@export var COIN_COLOR: Color = Color.GOLD

# === Какие клавиши "нажимают" экранные кнопки ===
@export_group("Simulated Keys")
@export var SIM_KEY_LEFT: Key = KEY_LEFT
@export var SIM_KEY_RIGHT: Key = KEY_RIGHT
@export var SIM_KEY_JUMP: Key = KEY_SPACE
# =====================================

@onready var coconut_mesh: MeshInstance3D = $RollPivot/Coconut224Tris
@onready var roll_pivot: Node3D = $RollPivot
@onready var message_label: Label = $CanvasLayer/MessageLabel
@onready var coin_label: Label = $CanvasLayer/CoinsLabel
@onready var breack_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

# ⭐ Экранные кнопки
@onready var left_button: Button = $CanvasLayer/LeftButton
@onready var right_button: Button = $CanvasLayer/RightButton2
@onready var jump_button: Button = $CanvasLayer/JumpButton3

# Компоненты
var _movement: CoconutMovement
var _roller: CoconutRoller
var _health: CoconutHealth
var _collision_handler: CoconutCollisionHandler

# ⭐ Счётчик собранных монет
var coins_collected: int = 0

func _ready() -> void:
	add_to_group("player")
	breack_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	# Инициализация логики
	_health = CoconutHealth.new()
	_health.broken.connect(_on_broken)
	
	_movement = CoconutMovement.new(self)
	_movement.speed = SPEED
	_movement.jump_velocity = JUMP_VELOCITY
	
	_roller = CoconutRoller.new(roll_pivot, coconut_mesh)
	_roller.spin_boost = SPIN_BOOST
	
	_collision_handler = CoconutCollisionHandler.new(self, _health)
	
	# ⭐ Подключаем кнопки-симуляторы
	_connect_ui_buttons()
	
	# Настраиваем UI
	_apply_message_style()
	_apply_coin_label_style()
	_update_coin_label()

# --- ⭐ Кнопки симулируют нажатия клавиш ---
func _connect_ui_buttons() -> void:
	left_button.button_down.connect(func() -> void: _simulate_key(SIM_KEY_LEFT, true))
	left_button.button_up.connect(func() -> void: _simulate_key(SIM_KEY_LEFT, false))
	
	right_button.button_down.connect(func() -> void: _simulate_key(SIM_KEY_RIGHT, true))
	right_button.button_up.connect(func() -> void: _simulate_key(SIM_KEY_RIGHT, false))
	
	jump_button.button_down.connect(func() -> void: _simulate_key(SIM_KEY_JUMP, true))
	jump_button.button_up.connect(func() -> void: _simulate_key(SIM_KEY_JUMP, false))
	
	# Кнопки не должны перехватывать фокус клавиатуры
	for btn: Button in [left_button, right_button, jump_button]:
		btn.focus_mode = Control.FOCUS_NONE

# --- ⭐ "Призрачное" нажатие клавиши ---
func _simulate_key(keycode: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode  # работает и с is_key_pressed, и с is_physical_key_pressed
	event.pressed = pressed
	event.echo = false
	Input.parse_input_event(event)

# --- Отпускаем все виртуальные клавиши (защита от "залипания") ---
func _release_all_sim_keys() -> void:
	_simulate_key(SIM_KEY_LEFT, false)
	_simulate_key(SIM_KEY_RIGHT, false)
	_simulate_key(SIM_KEY_JUMP, false)

func _exit_tree() -> void:
	_release_all_sim_keys()

func _physics_process(delta: float) -> void:
	if _health.is_broken():
		return
	
	# Никаких external_axis — компонент читает Input как обычно!
	_movement.update(delta)
	_roller.update(velocity, delta)
	_collision_handler.check_collisions()

# --- Методы монет и стиля без изменений ---
func add_coin(value: int) -> void:
	coins_collected += value
	_update_coin_label()
	print("💰 Всего монет у кокоса: ", coins_collected)

func _update_coin_label() -> void:
	coin_label.text = "🪙 x " + str(coins_collected)

func _apply_coin_label_style() -> void:
	coin_label.add_theme_font_size_override("font_size", COIN_FONT_SIZE)
	coin_label.add_theme_color_override("font_color", COIN_COLOR)
	coin_label.add_theme_color_override("font_outline_color", Color.BLACK)
	coin_label.add_theme_constant_override("outline_size", 8)
	coin_label.position = Vector2(24, 24)

func _apply_message_style() -> void:
	message_label.visible = false
	message_label.text = MESSAGE_TEXT
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", MESSAGE_FONT_SIZE)
	message_label.add_theme_color_override("font_color", MESSAGE_COLOR)
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = MESSAGE_BG_COLOR
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	style_box.content_margin_left = 40
	style_box.content_margin_right = 40
	style_box.content_margin_top = 20
	style_box.content_margin_bottom = 20
	message_label.add_theme_stylebox_override("normal", style_box)

# Добавьте эту новую функцию в конец файла coconut_player.gd
func _save_high_score_if_needed() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://highscore.cfg")
	var current_high_score = 0
	
	# Если файл уже существует, читаем текущий рекорд
	if err == OK:
		current_high_score = config.get_value("game", "high_score", 0)
	
	# Если собрали больше, чем было, сохраняем новый рекорд
	if coins_collected > current_high_score:
		config.set_value("game", "high_score", coins_collected)
		config.save("user://highscore.cfg")
		print("🏆 Новый рекорд сохранён: ", coins_collected)
	else:
		print("📊 Текущий рекорд: ", current_high_score, ". Собрано в этот раз: ", coins_collected)


# Обновите существующую функцию _on_broken(), добавив одну строку:
func _on_broken() -> void:
	print("💥 Кокос разбился! Запускаем логику смерти...")
	
	# 1. Отпускаем виртуальные кнопки, чтобы они не "залипли" на паузе
	_release_all_sim_keys()  
	
	# 2. Проигрываем звук
	breack_sound.play()
	
	# 3. Показываем UI и ставим игру на паузу
	message_label.visible = true
	get_tree().paused = true
	
	# ⭐ ДОБАВЬТЕ ЭТУ СТРОКУ: Проверяем и сохраняем рекорд монет ⭐
	_save_high_score_if_needed()
	
	# 4. Ждем 3 секунды (таймер работает даже на паузе благодаря true)
	await get_tree().create_timer(MESSAGE_DELAY, true).timeout
	
	# 5. Логика после паузы
	print("Собрано монет за забег: ", coins_collected)
	MusicManager.next_track()
	
	# 6. Снимаем паузу и перезагружаем сцену
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")
