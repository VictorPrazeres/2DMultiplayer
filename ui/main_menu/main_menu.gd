extends Control

const PORT: int = 3000

var main_scene: PackedScene = preload("uid://bwtumf0ncui6b")

@onready var host_button: Button = $HContainer/HostButton
@onready var join_button: Button = $HContainer/JoinButton


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_host_pressed() -> void:
	var server_peer := ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	multiplayer.multiplayer_peer = server_peer
	get_tree().change_scene_to_packed(main_scene)


func _on_join_pressed() -> void:
	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client("127.0.0.1", PORT)
	multiplayer.multiplayer_peer = client_peer


func _on_connected_to_server():
	get_tree().change_scene_to_packed(main_scene)
