# CoconutRoller.gd
extends RefCounted

class_name CoconutRoller

var _pivot: Node3D
var _mesh: MeshInstance3D
var _roll_angle: float = 0.0
var _roll_radius: float = 0.75
var spin_boost: float = 6.0

func _init(pivot: Node3D, mesh: MeshInstance3D) -> void:
	_pivot = pivot
	_mesh = mesh
	_calculate_radius()

func _calculate_radius() -> void:
	_roll_radius = _mesh.get_aabb().size.y * 0.5 * _mesh.scale.y

func update(velocity: Vector3, delta: float) -> void:
	var distance: float = velocity.x * delta
	_roll_angle -= distance / _roll_radius * spin_boost
	_pivot.rotation.z = _roll_angle
