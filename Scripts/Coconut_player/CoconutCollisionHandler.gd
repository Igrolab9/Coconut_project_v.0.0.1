# CoconutCollisionHandler.gd
extends RefCounted

class_name CoconutCollisionHandler

const DAMAGABLE_GROUP: StringName = &"Damagable_objects"

var _body: CharacterBody3D
var _health: CoconutHealth

func _init(body: CharacterBody3D, health: CoconutHealth) -> void:
	_body = body
	_health = health

func check_collisions() -> void:
	for i in _body.get_slide_collision_count():
		var collision: KinematicCollision3D = _body.get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if _is_in_damagable_group(collider):
			_health.take_damage()
			print("Take damage")
			return

func _is_in_damagable_group(collider: Object) -> bool:
	var node: Node = collider as Node
	while node != null:
		if node.is_in_group(DAMAGABLE_GROUP):
			return true
		node = node.get_parent()
	return false
