class_name Bullet extends Node2D

const SPEED: int = 600

var direction: Vector2


func _process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(direction: Vector2):
	self.direction = direction
	rotation = direction.angle()
