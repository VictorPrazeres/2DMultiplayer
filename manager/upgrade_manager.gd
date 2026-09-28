extends Node

@export var enemy_manager: EnemyManager
@export var spawn_position: Node2D
@export var spawn_root: Node
@export var available_upgrades: Array[UpgradeResource]

var upgrade_option_scene: PackedScene = preload("uid://ct03qmkkn8y56")


func _ready() -> void:
	enemy_manager.round_completed.connect(_on_round_completed)


func generate_upgrade_options():
	var connected_peers_ids := multiplayer.get_peers()
	connected_peers_ids.append(MultiplayerPeer.TARGET_PEER_SERVER)
	for connected_peers_id in connected_peers_ids:
		var selected_upgrades := [available_upgrades[0].id, available_upgrades[0].id, available_upgrades[0].id]
		set_upgrade_options.rpc_id(connected_peers_id, selected_upgrades)


func show_upgrade_resources(upgrade_resources: Array[UpgradeResource]):
	var initial_x = -64
	var x_difference = 64
	
	for i in range(upgrade_resources.size()):
		var upgrade_option: UpgradeOption = upgrade_option_scene.instantiate()
		upgrade_option.global_position = spawn_position.global_position
		
		upgrade_option.global_position += Vector2.RIGHT * (initial_x + (x_difference * i))
		
		spawn_root.add_child(upgrade_option)


@rpc("authority", "call_local", "reliable")
func set_upgrade_options(upgrade_ids: Array):
	var upgrade_resources: Array[UpgradeResource] = []
	for upgrade_id in upgrade_ids:
		var resource_index := available_upgrades.find_custom(func (item: UpgradeResource):
			return item.id == upgrade_id
		)
		upgrade_resources.append(available_upgrades[resource_index])
	
	show_upgrade_resources(upgrade_resources)


func _on_round_completed():
	generate_upgrade_options()
