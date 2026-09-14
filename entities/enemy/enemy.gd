extends CharacterBody2D

var target_position: Vector2

@onready var hurtbox: Area2D = $Hurtbox
@onready var target_acquisition_timer: Timer = $TargetAcquisitionTimer
@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	hurtbox.area_entered.connect(_on_area_entered)
	target_acquisition_timer.timeout.connect(_on_target_acquisition_timer_timeout)
	
	if is_multiplayer_authority():
		health_component.died.connect(_on_died)
		acquire_target()


func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		velocity = global_position.direction_to(target_position) * 40
		move_and_slide()


func handle_hit():
	health_component.damage(1)


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


func _on_area_entered(other_area: Area2D):
	if !is_multiplayer_authority():
		return
	if other_area.owner is Bullet:
		var bullet = other_area.owner as Bullet
		bullet.register_collision()
		handle_hit()


func _on_target_acquisition_timer_timeout():
	if is_multiplayer_authority():
		acquire_target()


func _on_died():
	GameEvents.emit_enemy_died()
	queue_free()
