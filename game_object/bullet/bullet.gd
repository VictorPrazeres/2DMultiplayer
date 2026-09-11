class_name Bullet extends Node2D

const SPEED: int = 600

var direction: Vector2

@onready var life_timer: Timer = $LifeTimer


func _ready() -> void:
	life_timer.timeout.connect(_on_life_timer_timeout)


func _process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(_direction: Vector2):
	self.direction = _direction
	rotation = _direction.angle()


func register_collision():
	queue_free()


func _on_life_timer_timeout():
	if is_multiplayer_authority():
		queue_free()
