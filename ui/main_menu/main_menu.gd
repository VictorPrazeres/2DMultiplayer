extends Control

@onready var host_button: Button = $HContainer/HostButton
@onready var play_button: Button = $HContainer/PlayButton


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	play_button.pressed.connect(_on_play_pressed)


func _on_host_pressed() -> void:
	print("host pressed")


func _on_play_pressed() -> void:
	print("play pressed")
