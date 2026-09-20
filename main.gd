extends Node

const MAIN_MENU_SCENE_PATH := "res://ui/main_menu/main_menu.tscn"

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
	multiplayer.server_disconnected.connect(_on_server_disconnected)


@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
	enemy_manager.synchronize(sender_id)
	
	print(multiplayer.get_peers())


func respawn_dead_peers():
	for peer_id in dead_peers:
		multiplayer_spawner.spawn({"peer_id": peer_id})
	dead_peers.clear()


func end_game():
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func check_game_over():
	var is_game_over := true
	var all_peers := multiplayer.get_peers()
	all_peers.push_back(multiplayer.get_unique_id())
	
	for peer_id in all_peers:
		if !dead_peers.has(peer_id):
			is_game_over = false
			break
	
	if is_game_over:
		end_game()


func _on_player_died(peer_id: int):
	dead_peers.append(peer_id)
	check_game_over()


func _on_round_completed():
	respawn_dead_peers()


func _on_server_disconnected():
	end_game()
