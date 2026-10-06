extends CanvasLayer

@onready var sfx_down_button: Button = %SfxDownButton
@onready var sfx_progress_bar: ProgressBar = %SfxProgressBar
@onready var sfx_up_button: Button = %SfxUpButton
@onready var music_down_button: Button = %MusicDownButton
@onready var music_progress_bar: ProgressBar = %MusicProgressBar
@onready var music_up_button: Button = %MusicUpButton
@onready var done_button: Button = %DoneButton


func _ready() -> void:
	update_display()
	
	sfx_down_button.pressed.connect(_on_down_pressed.bind("sfx"))
	sfx_up_button.pressed.connect(_on_up_pressed.bind("sfx"))
	
	music_down_button.pressed.connect(_on_down_pressed.bind("music"))
	music_up_button.pressed.connect(_on_up_pressed.bind("music"))
	
	done_button.pressed.connect(_on_done_pressed)
	
	UIAudioManager.register_buttons([
		sfx_down_button,
		sfx_up_button,
		music_down_button,
		music_up_button,
		done_button
	])


func update_display():
	sfx_progress_bar.value = get_bus_volume("sfx")
	music_progress_bar.value = get_bus_volume("music")


func get_bus_volume(bus_name: String) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_volume_linear(index)


func change_bus_volume(bus_name: String, linear_change: float):
	var current_volume_linear := get_bus_volume(bus_name)
	var index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(index, clamp(current_volume_linear + linear_change, 0, 1))
	update_display()


func _on_down_pressed(bus_name: String):
	change_bus_volume(bus_name, -.1)


func _on_up_pressed(bus_name: String):
	change_bus_volume(bus_name, .1)


func _on_done_pressed():
	queue_free()
