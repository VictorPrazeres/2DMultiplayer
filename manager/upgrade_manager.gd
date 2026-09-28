extends Node

@export var enemy_manager: EnemyManager
@export var spawn_position: Node2D
@export var spawn_root: Node
@export var available_upgrades: Array[UpgradeResource]

var upgrade_option_scene: PackedScene = preload("uid://ct03qmkkn8y56")


func _ready() -> void:
	enemy_manager.round_completed.connect(_on_round_completed)


func _on_round_completed():
	var upgrade_option: UpgradeOption = upgrade_option_scene.instantiate()
	upgrade_option.global_position = spawn_position.global_position
	spawn_root.add_child(upgrade_option)
