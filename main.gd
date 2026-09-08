extends Node

var player_scene: PackedScene = preload("uid://cjqc31ns8shcp")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


func _ready() -> void:
	multiplayer_spawner.spawn_function = func(data):
		var player = player_scene.instantiate() as Player
		player.name = str(data.peer_id)
		player.input_multiplayer_authority = data.peer_id
		return player
	
	peer_ready.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
