extends Node

var player_scene: PackedScene = preload("uid://cjqc31ns8shcp")
var dead_peers: Array[int] = []

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition
@onready var enemy_manager: EnemyManager = $EnemyManager


func _ready() -> void:
	multiplayer_spawner.spawn_function = func(data):
		var player = player_scene.instantiate() as Player
		player.name = str(data.peer_id)
		player.input_multiplayer_authority = data.peer_id
		player.global_position = player_spawn_position.global_position
		
		if is_multiplayer_authority():
			player.died.connect(_on_player_died.bind(data.peer_id))
		
		return player
	
	peer_ready.rpc_id(1)
	enemy_manager.round_completed.connect(_on_round_completed)


@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
	enemy_manager.synchronize(sender_id)


func respawn_dead_peers():
	for peer_id in dead_peers:
		multiplayer_spawner.spawn({"peer_id": peer_id})
	dead_peers.clear()


func _on_player_died(peer_id: int):
	dead_peers.append(peer_id)


func _on_round_completed():
	respawn_dead_peers()
