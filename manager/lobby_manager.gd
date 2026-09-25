class_name LobbyManager extends Node

signal all_peers_ready
signal self_peer_ready
signal lobby_closed

var ready_peer_ids: Array[int] = []
var is_lobby_closed: bool:
	get:
		return _is_lobby_closed
	set(value):
		_is_lobby_closed = value
		if _is_lobby_closed:
			lobby_closed.emit()

var _is_lobby_closed: bool


func _ready() -> void:
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		all_peers_ready.emit.call_deferred()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lobby_ready"):
		request_peer_ready.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
		get_viewport().set_input_as_handled()


func close_lobby():
	is_lobby_closed = true


@rpc("authority", "call_local", "reliable")
func set_peer_ready(peer_id: int):
	if peer_id == multiplayer.get_unique_id():
		self_peer_ready.emit()
	
	if !ready_peer_ids.has(peer_id):
		ready_peer_ids.append(peer_id)


@rpc("any_peer", "call_local", "reliable")
func request_peer_ready():
	if !is_multiplayer_authority() || is_lobby_closed:
		return
	
	var sender_id := multiplayer.get_remote_sender_id()
	set_peer_ready.rpc(sender_id)
	
	try_all_peers_ready()


func try_all_peers_ready():
	if check_all_peers_ready():
		all_peers_ready.emit()


func check_all_peers_ready() -> bool:
	var all_peers := multiplayer.get_peers()
	all_peers.append(MultiplayerPeer.TARGET_PEER_SERVER)
	
	for peer_id in all_peers:
		if !ready_peer_ids.has(peer_id):
			return false
	return true


func _on_peer_disconnected(_peer_id: int):
	try_all_peers_ready()
