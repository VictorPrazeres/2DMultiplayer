extends MarginContainer

var main_scene: PackedScene = preload("uid://bwtumf0ncui6b")
var port_number: int
var ip_address: String

@onready var display_name_text_edit: TextEdit = %DisplayNameTextEdit
@onready var port_text_edit: TextEdit = %PortTextEdit
@onready var ip_address_text_edit: TextEdit = %IPAddressTextEdit
@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton
@onready var main_menu_scene: PackedScene = load("uid://blnldpigbtvf6")


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	
	display_name_text_edit.text_changed.connect(_on_text_changed)
	ip_address_text_edit.text_changed.connect(_on_text_changed)
	port_text_edit.text_changed.connect(_on_text_changed)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	validate()


func validate():
	var port := port_text_edit.text
	if port.is_valid_int():
		port_number = int(port)
		if port_number <= 0:
			port_number = -1
	else:
		port_number = -1
	
	var ip := ip_address_text_edit.text
	if ip.is_valid_ip_address():
		ip_address = ip
	else:
		ip_address = ""
	
	var is_valid_port := port_number > 0
	var is_valid_name := !display_name_text_edit.text.is_empty()
	var is_valid_ip := !ip_address.is_empty()
	
	host_button.disabled = !is_valid_port || !is_valid_name
	join_button.disabled = !is_valid_port || !is_valid_name || !is_valid_ip


func _on_host_pressed() -> void:
	var server_peer := ENetMultiplayerPeer.new()
	server_peer.create_server(port_number)
	multiplayer.multiplayer_peer = server_peer
	get_tree().change_scene_to_packed(main_scene)


func _on_join_pressed() -> void:
	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client(ip_address, port_number)
	multiplayer.multiplayer_peer = client_peer


func _on_connected_to_server():
	get_tree().change_scene_to_packed(main_scene)


func _on_back_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_text_changed():
	validate()
