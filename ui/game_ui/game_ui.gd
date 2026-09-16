extends CanvasLayer

@export var enemy_manager: EnemyManager

@onready var timer_label: Label = %TimerLabel
@onready var round_label: Label = %RoundLabel


func _ready() -> void:
	enemy_manager.round_began.connect(_on_round_began)


func _process(_delta: float) -> void:
	timer_label.text = str(ceili(enemy_manager.get_round_time_remaining()))


func _on_round_began(round_count: int):
	round_label.text = "Round %s" % round_count
