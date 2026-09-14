extends Node

signal enemy_died


func emit_enemy_died():
	enemy_died.emit()
