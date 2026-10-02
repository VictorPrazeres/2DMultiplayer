class_name UpgradeManager extends Node

signal upgrades_completed

static var instance: UpgradeManager

@export var enemy_manager: EnemyManager
@export var spawn_position: Node2D
@export var spawn_root: Node
@export var available_upgrades: Array[UpgradeResource]

var upgrade_option_scene: PackedScene = preload("uid://ct03qmkkn8y56")
var peer_id_to_upgrade_options: Dictionary[int, Array] = {}
var peer_id_to_upgrades_acquired: Dictionary[int, Dictionary] = {}
var outstanding_peers_to_upgrade: Array[int] = []


static func get_peer_upgrade_count(peer_id: int, upgrade_id: String) -> int:
	if !is_instance_valid(instance):
		return 0
	
	if !instance.peer_id_to_upgrades_acquired.has(peer_id):
		return 0
	
	if !instance.peer_id_to_upgrades_acquired[peer_id].has(upgrade_id):
		return 0
	
	return instance.peer_id_to_upgrades_acquired[peer_id][upgrade_id]


static func peer_has_upgrade(peer_id: int, upgrade_id: String) -> bool:
	return get_peer_upgrade_count(peer_id, upgrade_id) > 0


func _ready() -> void:
	instance = self
	enemy_manager.round_completed.connect(_on_round_completed)
	
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func generate_upgrade_options():
	peer_id_to_upgrade_options.clear()
	var connected_peers_ids := multiplayer.get_peers()
	connected_peers_ids.append(MultiplayerPeer.TARGET_PEER_SERVER)
	for connected_peer_id in connected_peers_ids:
		outstanding_peers_to_upgrade.append(connected_peer_id)
		
		var available_upgrades_copy := Array(available_upgrades)
		available_upgrades_copy.shuffle()
		
		var chosen_upgrades := available_upgrades_copy.slice(0, 3)
		peer_id_to_upgrade_options[connected_peer_id] = chosen_upgrades
		
		var upgrade_options := create_upgrade_option_nodes(chosen_upgrades)
		var selected_upgrades: Array = []
		for i in upgrade_options.size():
			var upgrade_option := upgrade_options[i]
			var upgrade_resource := chosen_upgrades[i] as UpgradeResource
			upgrade_option.set_peer_id_filter(connected_peer_id)
			var uid := ResourceUID.create_id()
			upgrade_option.name = str(uid)
			
			selected_upgrades.append({
				"name": upgrade_option.name,
				"id": upgrade_resource.id
			})
			
			upgrade_option.visible = connected_peer_id == MultiplayerPeer.TARGET_PEER_SERVER
		
		if connected_peer_id != MultiplayerPeer.TARGET_PEER_SERVER:
			set_upgrade_options.rpc_id(connected_peer_id, selected_upgrades)


func create_upgrade_option_nodes(upgrade_resources: Array[UpgradeResource]) -> Array[UpgradeOption]:
	var result: Array[UpgradeOption] = []
	var initial_x = -64
	var x_difference = 64
	
	for i in range(upgrade_resources.size()):
		var upgrade_option: UpgradeOption = upgrade_option_scene.instantiate()
		upgrade_option.set_upgrade_index(i)
		upgrade_option.set_upgrade_resource(upgrade_resources[i])
		
		upgrade_option.global_position = spawn_position.global_position
		upgrade_option.global_position += Vector2.RIGHT * (initial_x + (x_difference * i))
		spawn_root.add_child(upgrade_option)
		
		upgrade_option.selected.connect(_on_upgrade_option_selected)
		result.append(upgrade_option)
	
	return result


@rpc("authority", "call_local", "reliable")
func set_upgrade_options(selected_upgrades: Array):
	var upgrade_resources: Array[UpgradeResource] = []
	for upgrade in selected_upgrades:
		var resource_index := available_upgrades.find_custom(func (item: UpgradeResource):
			return item.id == upgrade.id
		)
		upgrade_resources.append(available_upgrades[resource_index])
	
	var created_nodes := create_upgrade_option_nodes(upgrade_resources)
	for i in created_nodes.size():
		created_nodes[i].name = selected_upgrades[i].name


func handle_upgrade_selected(upgrade_index: int, for_peer_id: int):
	if !peer_id_to_upgrades_acquired.has(for_peer_id):
		peer_id_to_upgrades_acquired[for_peer_id] = {}
	
	var upgrade_dictionary := peer_id_to_upgrades_acquired[for_peer_id]
	var chosen_upgrade = peer_id_to_upgrade_options[for_peer_id][upgrade_index]
	
	var upgrade_count: int = 0
	if upgrade_dictionary.has(chosen_upgrade.id):
		upgrade_count = upgrade_dictionary[chosen_upgrade.id]
	
	upgrade_dictionary[chosen_upgrade.id] = upgrade_count + 1
	
	outstanding_peers_to_upgrade.erase(for_peer_id)
	
	print("Peer %s has selected upgrade with id %s" % [
		for_peer_id,
		peer_id_to_upgrade_options[for_peer_id][upgrade_index].id
	])
	
	check_upgrades_completed()


func check_upgrades_completed():
	if outstanding_peers_to_upgrade.size() > 0:
		return
	
	upgrades_completed.emit()


func _on_round_completed():
	generate_upgrade_options()


func _on_upgrade_option_selected(upgrade_index: int, for_peer_id: int):
	handle_upgrade_selected(upgrade_index, for_peer_id)


func _on_peer_disconnected(peer_id: int):
	if outstanding_peers_to_upgrade.has(peer_id):
		outstanding_peers_to_upgrade.erase(peer_id)
		check_upgrades_completed()
