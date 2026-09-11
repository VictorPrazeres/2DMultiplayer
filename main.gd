extends Node

var player_scene: PackedScene = preload("uid://cjqc31ns8shcp")
var enemy_scene: PackedScene = preload("uid://dm0754lgs1m7u")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


func _ready() -> void:
	multiplayer_spawner.spawn_function = func(data):
		var player = player_scene.instantiate() as Player
		player.name = str(data.peer_id)
		player.input_multiplayer_authority = data.peer_id
		return player
	
	peer_ready.rpc_id(1)
	
	if is_multiplayer_authority():
		var enemy = enemy_scene.instantiate() as Node2D
		enemy.global_position = Vector2.ONE * 100
		add_child(enemy)


@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
