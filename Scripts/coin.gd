extends Area3D

@export var score_value: int = 1  # Сколько очков даёт монетка

@onready var coin_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var coin_mesh: Node3D = $PirateCoin
@onready var coin_shape: CollisionShape3D = $CollisionShape3D

var collected: bool = false  # защита от двойного сбора

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if collected:
		return
	if body.is_in_group("player"):
		if body.has_method("add_coin"):
			body.add_coin(score_value)
		collect_coin()

func collect_coin() -> void:
	collected = true
	print("🪙 Монета собрана! +", score_value, " очков")
	
	# 1. Монета мгновенно "исчезает" для игрока:
	set_deferred("monitoring", false)      # больше не ловит тела
	coin_shape.set_deferred("disabled", true)  # коллизия выключена
	coin_mesh.visible = false              # модель скрыта
	
	# 2. Звук играет ДО конца жизни узла:
	coin_sound.play()
	coin_sound.finished.connect(queue_free)  # ⭐ удаляемся ТОЛЬКО когда звук дозвучал
