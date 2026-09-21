class_name HealthComponent extends Node

signal died
signal damaged

@export var max_health: int = 1

var current_health: int


func _ready() -> void:
	current_health = max_health


func damage(amount: int):
	current_health = clamp(current_health - amount, 0, max_health)
	damaged.emit()
	if current_health == 0:
		died.emit()
