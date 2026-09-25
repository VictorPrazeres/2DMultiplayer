class_name LobbyManager extends Node

signal all_peers_ready
signal self_peer_ready
signal lobby_closed
signal peer_ready_states_changed(peers_ready: int, peers_total: int)

var ready_peer_ids: Array[int] = []:
	get:
		return _ready_peer_ids
	set(value):
		_ready_peer_ids = value
		emit_peer_ready_states_changed()
var is_lobby_closed: bool:
	get:
		return _is_lobby_closed
	set(value):
		_is_lobby_closed = value
		if _is_lobby_closed:
			lobby_closed.emit()

var _is_lobby_closed: bool
var _ready_peer_ids: Array[int] = []


func _ready() -> void:
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		all_peers_ready.emit.call_deferred()
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	emit_peer_ready_states_changed.call_deferred()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lobby_ready"):
		request_peer_ready.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
		get_viewport().set_input_as_handled()


func close_lobby():
	is_lobby_closed = true


func emit_peer_ready_states_changed():
	var connected_peer_count: int = multiplayer.get_peers().size() + 1
	peer_ready_states_changed.emit(ready_peer_ids.size(), connected_peer_count)


@rpc("authority", "call_local", "reliable")
func set_peer_ready(peer_id: int):
	if peer_id == multiplayer.get_unique_id():
		self_peer_ready.emit()


@rpc("any_peer", "call_local", "reliable")
func request_peer_ready():
	if !is_multiplayer_authority() || is_lobby_closed:
		return
	
	var sender_id := multiplayer.get_remote_sender_id()
	
	if !ready_peer_ids.has(sender_id):
		ready_peer_ids.append(sender_id)
		emit_peer_ready_states_changed()
	
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


func _on_peer_disconnected(peer_id: int):
	if is_lobby_closed:
		return
	
	if ready_peer_ids.has(peer_id):
		ready_peer_ids.erase(peer_id)
		emit_peer_ready_states_changed()
	try_all_peers_ready()


func _on_peer_connected(_peer_id: int):
	if is_lobby_closed:
		return
	
	emit_peer_ready_states_changed()
