class_name UpgradeOption extends Node2D

signal selected(index: int, for_peer_id: int)

var upgrade_index: int
var peer_id_filter: int
var assigned_resource: UpgradeResource

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
	hurtbox_component.peer_id_filter = peer_id_filter
	health_component.died.connect(_on_died)
	
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func set_peer_id_filter(new_peer_id: int):
	peer_id_filter = new_peer_id
	hurtbox_component.peer_id_filter = peer_id_filter


func set_upgrade_index(index: int):
	upgrade_index = index


func set_upgrade_resource(upgrade_resource: UpgradeResource):
	assigned_resource = upgrade_resource


func kill():
	queue_free()


@rpc("authority", "call_local", "reliable")
func kill_all():
	var upgrade_option_nodes := get_tree().get_nodes_in_group("upgrade_option")
	
	for upgrade_option in upgrade_option_nodes:
		if upgrade_option.peer_id_filter == peer_id_filter:
			upgrade_option.kill()


func _on_died():
	selected.emit(upgrade_index, peer_id_filter)
	kill_all.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
	
	if peer_id_filter != MultiplayerPeer.TARGET_PEER_SERVER:
		kill_all.rpc_id(peer_id_filter)


func _on_peer_disconnected(peer_id: int):
	if peer_id == peer_id_filter:
		kill()
