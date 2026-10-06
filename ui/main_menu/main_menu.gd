extends Control

var main_scene: PackedScene = preload("uid://bwtumf0ncui6b")
var options_menu_scene: PackedScene = preload("uid://def06ruty6wid")

@onready var single_player_button: Button = $VContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VContainer/MultiplayerButton
@onready var quit_button: Button = $VContainer/QuitButton
@onready var multiplayer_menu_scene: PackedScene = load("uid://cye5o3nx6oi3h")
@onready var options_button: Button = $VContainer/OptionsButton


func _ready() -> void:
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.pressed.connect(_on_options_pressed)
	
	UIAudioManager.register_buttons([
		single_player_button,
		multiplayer_button,
		quit_button,
		options_button
	])


func _on_single_player_button_pressed():
	get_tree().change_scene_to_packed(main_scene)


func _on_multiplayer_button_pressed():
	get_tree().change_scene_to_packed(multiplayer_menu_scene)


func _on_quit_button_pressed():
	get_tree().quit()


func _on_options_pressed():
	var options_menu := options_menu_scene.instantiate()
	add_child(options_menu)
