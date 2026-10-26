# CoconutMovement.gd Передвижение кокоса
extends RefCounted
class_name CoconutMovement

var _body: CharacterBody3D
var speed: float = 1.0
var jump_velocity: float = 4.0

func _init(body: CharacterBody3D) -> void:
	_body = body

func update(delta: float) -> void:
	# Гравитация
	if not _body.is_on_floor():
		_body.velocity += _body.get_gravity() * delta

	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and _body.is_on_floor():
		_body.velocity.y = jump_velocity

	# Движение (в твоем случае X - постоянная скорость, Z - управление)
	_body.velocity.x = speed
	
	var input_dir := Input.get_vector("ui_down", "ui_up", "ui_left", "ui_right")
	var direction := (_body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		_body.velocity.z = direction.z * speed
	else:
		_body.velocity.z = move_toward(_body.velocity.z, 0, speed)

	_body.move_and_slide()
