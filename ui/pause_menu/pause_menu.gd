class_name PauseMenu extends CanvasLayer

signal quit_requested

var current_paused_peer: int = -1
var options_menu_scene: PackedScene = preload("uid://def06ruty6wid")

@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var options_button: Button = %OptionsButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	options_button.pressed.connect(_on_options_pressed)
	
	UIAudioManager.register_buttons([
		resume_button,
		quit_button,
		options_button
	])
	
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			request_unpause.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
		else:
			request_pause.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
		get_viewport().set_input_as_handled()


@rpc("any_peer", "call_local", "reliable")
func request_pause():
	if current_paused_peer > -1:
		return
	pause.rpc(multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local", "reliable")
func request_unpause():
	if current_paused_peer != multiplayer.get_remote_sender_id():
		return
	unpause.rpc()


@rpc("authority", "call_local", "reliable")
func pause(paused_peer: int):
	get_tree().paused = true
	visible = true
	current_paused_peer = paused_peer
	
	var is_controlling_player := current_paused_peer == multiplayer.get_unique_id()
	resume_button.disabled = !is_controlling_player
	options_button.disabled = !is_controlling_player


@rpc("authority", "call_local", "reliable")
func unpause():
	get_tree().paused = false
	visible = false
	current_paused_peer = -1


func _on_resume_pressed():
	request_unpause.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)


func _on_quit_pressed():
	quit_requested.emit()


func _on_peer_disconnected(peer_id: int):
	if current_paused_peer == peer_id:
		unpause.rpc()


func _on_options_pressed():
	var options_menu := options_menu_scene.instantiate()
	add_child(options_menu)
