extends Control

var main_scene: PackedScene = preload("uid://bwtumf0ncui6b")

@onready var single_player_button: Button = $VContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VContainer/MultiplayerButton
@onready var quit_button: Button = $VContainer/QuitButton
@onready var multiplayer_menu_scene: PackedScene = load("uid://cye5o3nx6oi3h")


func _ready() -> void:
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func _on_single_player_button_pressed():
	get_tree().change_scene_to_packed(main_scene)


func _on_multiplayer_button_pressed():
	get_tree().change_scene_to_packed(multiplayer_menu_scene)


func _on_quit_button_pressed():
	get_tree().quit()
