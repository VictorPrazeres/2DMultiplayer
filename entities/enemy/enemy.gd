extends CharacterBody2D

var target_position: Vector2
var state_machine: CallableStateMachine = CallableStateMachine.new()

@onready var target_acquisition_timer: Timer = $TargetAcquisitionTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals


func _ready() -> void:
	state_machine.add_states(state_spawn, enter_state_spawn, Callable())
	state_machine.add_states(state_normal, enter_state_normal, Callable())
	state_machine.set_initial_state(state_spawn)
	
	target_acquisition_timer.timeout.connect(_on_target_acquisition_timer_timeout)
	
	if is_multiplayer_authority():
		health_component.died.connect(_on_died)


func _process(_delta: float) -> void:
	state_machine.update()
	if is_multiplayer_authority():
		move_and_slide()


func enter_state_spawn():
	var tween := create_tween()
	tween.tween_property(visuals, "scale", Vector2.ONE, .4).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func ():
		state_machine.change_state(state_normal)
	)


func state_spawn():
	pass


func enter_state_normal():
	if is_multiplayer_authority():
		acquire_target()


func state_normal():
	if is_multiplayer_authority():
		velocity = global_position.direction_to(target_position) * 40
	flip()


func flip():
	visuals.scale = Vector2.ONE if target_position.x > global_position.x else  Vector2(-1, 1)


func acquire_target():
	var players = get_tree().get_nodes_in_group("player")
	var nearest_player: Player = null
	var nearest_squared_distance: float
	
	for player in players:
		if nearest_player == null:
			nearest_player = player
			nearest_squared_distance = nearest_player.global_position.distance_squared_to(global_position)
			continue
		
		var player_squared_distance: float = player.global_position.distance_squared_to(global_position)
		if player_squared_distance < nearest_squared_distance:
			nearest_squared_distance = player_squared_distance
			nearest_player = player
	
	if nearest_player != null:
		target_position = nearest_player.global_position


func _on_target_acquisition_timer_timeout():
	if is_multiplayer_authority():
		acquire_target()


func _on_died():
	GameEvents.emit_enemy_died()
	queue_free()
