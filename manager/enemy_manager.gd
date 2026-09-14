extends Node

@export var enemy_scene: PackedScene
@export var enemy_spawn_root: Node
@export var spawn_rect: ReferenceRect

@onready var spawn_interval_timer: Timer = $SpawnIntervalTimer


func _ready() -> void:
	spawn_interval_timer.timeout.connect(_on_spawn_interval_timer_timeout)


func get_random_spawn_position() -> Vector2:
	var x = randi_range(0, int(spawn_rect.size.x))
	var y = randi_range(0, int(spawn_rect.size.y))
	
	return spawn_rect.global_position + Vector2(x, y)


func spawn_enemy():
	var enemy = enemy_scene.instantiate() as Node2D
	enemy.global_position = get_random_spawn_position()
	enemy_spawn_root.add_child(enemy, true)


func _on_spawn_interval_timer_timeout():
	if is_multiplayer_authority():
		spawn_enemy()
