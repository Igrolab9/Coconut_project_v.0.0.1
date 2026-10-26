# Спавнер деревьев: сажает деревья в случайных точках песчаной полосы.
# Вешается на корень платформы, чтобы деревья были её детьми
# и ездили вместе с ней при переработке пула.
extends Node3D

# "Мешок" с деревьями: перетащи сюда в инспекторе tree_1, tree_2, tree_3.
@export var objects_scenes: Array[PackedScene] = []

# Сколько обьектов сажать на одну платформу.
const OBJECTS_PER_PLATFORM: int = 20

# Зона спавна в ЛОКАЛЬНЫХ координатах платформы (X — вдоль дорожки, Z — поперёк).
# Vector2 хранит (x, z): минимальный угол и максимальный угол прямоугольника.
# Подбери числа под свою песчаную полосу: например, обойти середину, где бежит игрок.
@export var spawn_min: Vector2 = Vector2(0.8, 0.8)
@export var spawn_max: Vector2 = Vector2(9.0, 2.0)

# Список посаженных обьектов, чтобы уметь их вычистить перед пересадкой.
var _spawned_objects: Array[Node3D] = []

func _ready() -> void:
	respawn_trees() # при появлении платформы сразу сажаем деревья.

# Публичный метод: вычистить старые деревья и посадить новые в случайных местах.
# Пул может вызывать его после телепорта платформы, чтобы дорожка не повторялась.
func respawn_trees() -> void:
	_clear_trees()
	for i in OBJECTS_PER_PLATFORM:
		_plant_random_tree()

# Удаляем все ранее посаженные деревья.
func _clear_trees() -> void:
	for objects in _spawned_objects:
		if is_instance_valid(objects):
			objects.queue_free() # мягкое удаление: доживёт кадр и исчезнет.
	_spawned_objects.clear()

# Сажаем одно случайное дерево из мешка.
func _plant_random_tree() -> void:
	if objects_scenes.is_empty():
		push_warning("Спавнер обьектов: массив objects_scenes пустой!") # чтобы тишина не прятала причину.
		return
	var scene: PackedScene = objects_scenes[randi() % objects_scenes.size()] # случайный индекс масива.
	var object: Node3D = scene.instantiate()
	add_child(object) # ребёнок платформы = ездит с ней при переработке.
	object.position = _random_local_position()
	_spawned_objects.append(object)

# Случайная точка внутри прямоугольника зоны спавна.
func _random_local_position() -> Vector3:
	var x: float = randf_range(spawn_min.x, spawn_max.x) # вдоль дорожки.
	var z: float = randf_range(spawn_min.y, spawn_max.y) # поперёк: выбираем сторону/полосу.
	return Vector3(x, 0.05, z) # y = 0: стоим на поверхности песка платформы.
