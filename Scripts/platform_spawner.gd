# Наш скрипт — всё ещё житель 3D-мира и заведующий пулом платформ.
extends Node3D

# POOL_SIZE — сколько платформ заготовлено впрок (размер пула).
const POOL_SIZE : int = 9

# PLATFORM_LENGTH — длина одной платформы (10 единиц).
const PLATFORM_LENGTH : float = 10.0

# SPAWN_DIRECTION — направление, вдоль которого строится дорожка.
const SPAWN_DIRECTION : Vector3 = Vector3.RIGHT

# RECYCLE_TRIGGER_INDEX — номер платформы-«звоночка»:
# когда игрок добирает до платформы №4 (это ПЯТАЯ по счёту, ведь счёт с нуля!),
# пора переносить задние платформы вперёд.
const RECYCLE_TRIGGER_INDEX : int = 4

# RECYCLE_COUNT — сколько задних платформ переносим вперёд за один раз (4 штуки позади игрока).
const RECYCLE_COUNT : int = 4

# @export — переменная видна в инспекторе: туда мышкой перетаскиваем сцену платформы.
@export var platform_scene: PackedScene

# @export для игрока: перетащи игрока в это поле в инспекторе,
# чтобы пул знал, за кем «подглядывать».
@export var player: Node3D

# _platform_pool — ряд пронумерованных шкафчиков, в котором живут все платформы пула.
var _platform_pool: Array[Node3D] = []

# _ready() — звонок от движка: сцена стартовала, строим пул.
func _ready() -> void:
	_create_platform_pool() # "Построй пул платформ прямо сейчас!"

# _physics_process() — движок вызывает его каждый физический тик, как метроном.
# Тут мы подглядываем за игроком: не добежал ли он до 5-й платформы?
func _physics_process(_delta: float) -> void:
	_recycle_platforms_if_needed()

# _create_platform_pool() — строитель (фабрика): создаёт все платформы и ставит их в ряд.
func _create_platform_pool() -> void:
	_platform_pool.clear() # опустошаем шкафчики, чтобы не было дубликатов.
	for index in POOL_SIZE: # повторяем 9 раз: index = 0, 1, ... 8.
		var platform: Node3D = platform_scene.instantiate() # штампуем копию по образцу.
		add_child(platform) # добавляем на сцену, чтобы платформу было видно.
		_place_platform(platform, index) # ставим на место номер index * 10 единиц.
		_platform_pool.append(platform) # кладём в пул в конец ряда.

# _place_platform() — регулировщик: ставит платформу на её место в ряду.
func _place_platform(platform: Node3D, index: int) -> void:
	platform.position = SPAWN_DIRECTION * (index * PLATFORM_LENGTH)

# _recycle_platforms_if_needed() — сторож: проверяет, не пора ли устроить карусель.
func _recycle_platforms_if_needed() -> void:
	if player == null or _platform_pool.size() <= RECYCLE_TRIGGER_INDEX:
		print("Error of platform") 
		return
	var trigger_platform: Node3D = _platform_pool[RECYCLE_TRIGGER_INDEX] # 5-я платформа в ряду.
	# Если игрок по координате x дошёл (или добежал) до 5-й платформы — пора!
	if player.global_position.x >= trigger_platform.global_position.x:
		_move_behind_platforms_forward()

# _move_behind_platforms_forward() — карусель: берёт задние платформы и телепортирует их
# в самый конец ряда (вперёд по курсу). Новых платформ не создаём: переиспользуем старые,
# поэтому дорожка может крутиться бесконечно.
func _move_behind_platforms_forward() -> void:
	for i in RECYCLE_COUNT: # повторяем 4 раза — по одному на каждую заднюю платформу.
		var platform: Node3D = _platform_pool.pop_front() # достаём из ряда первую (самую заднюю).
		var last_platform: Node3D = _platform_pool[_platform_pool.size() - 1] # нынешний передний край ряда.
		# Ставим достанную платформу вплотную за передним краем — как скамейку к скамейке.
		platform.global_position = last_platform.global_position + SPAWN_DIRECTION * PLATFORM_LENGTH
		_platform_pool.append(platform) # теперь она последняя в ряду (и в шкафчиках тоже).
