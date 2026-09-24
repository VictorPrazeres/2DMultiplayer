class_name GameUI extends CanvasLayer

@export var enemy_manager: EnemyManager

@onready var timer_label: Label = %TimerLabel
@onready var round_label: Label = %RoundLabel
@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var display_name_label: Label = %DisplayNameLabel


func _ready() -> void:
	enemy_manager.round_changed.connect(_on_round_changed)


func _process(_delta: float) -> void:
	timer_label.text = str(ceili(enemy_manager.get_round_time_remaining()))


func connect_player(player: Player):
	(func ():
		if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
			display_name_label.text = "Player"
		else:
			display_name_label.text = player.display_name
		
		player.health_component.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health_component.current_health, player.health_component.max_health)
	).call_deferred()


func _on_round_changed(round_count: int):
	round_label.text = "Round %s" % round_count


func _on_health_changed(current_health: int, max_health: int):
	health_progress_bar.value = float(current_health) / max_health if max_health != 0 else 0
