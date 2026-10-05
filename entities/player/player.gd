class_name Player extends CharacterBody2D

signal died

const BASE_MOVEMENT_SPEED: float = 100
const BASE_FIRE_RATE: float = .25
const BASE_DAMAGE_BULLET: int = 1

var bullet_scene: PackedScene = preload("uid://dp5836u66xfiw")
var muzzle_flash_scene: PackedScene = preload("uid://bmaw6soihoeu7")
var input_multiplayer_authority: int
var is_dying: bool
var is_respawn: bool
var display_name: String

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var visuals: Node2D = $Visuals
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var barrel_position: Marker2D = %BarrelPosition
@onready var display_name_label: Label = $DisplayNameLabel
@onready var activation_area_collision_shape: CollisionShape2D = %ActivationAreaCollisionShape


func _ready() -> void:
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)
	activation_area_collision_shape.disabled = !player_input_synchronizer_component.is_multiplayer_authority()
	
	var is_single_player = multiplayer.multiplayer_peer is OfflineMultiplayerPeer
	var is_client_authority = player_input_synchronizer_component.is_multiplayer_authority()
	
	if  is_single_player || is_client_authority:
		display_name_label.visible = false
	else:
		display_name_label.text = display_name
	
	if is_multiplayer_authority():
		if is_respawn:
			health_component.current_health = 1
		health_component.died.connect(_on_died)


func _process(_delta: float) -> void:
	update_aim_position()
	if is_multiplayer_authority():
		if is_dying:
			global_position = Vector2.RIGHT * 1000
			return
	
		velocity = player_input_synchronizer_component.movement_vector * get_movement_speed()
		move_and_slide()
		if player_input_synchronizer_component.is_attack_pressed:
			try_fire()


func get_movement_speed() -> float:
	var movement_upgrade_count := UpgradeManager.get_peer_upgrade_count(
		player_input_synchronizer_component.get_multiplayer_authority(),
		"movement_speed"
	)
	
	var speed_modifier := 1 + (.15 * movement_upgrade_count)
	
	return BASE_MOVEMENT_SPEED * speed_modifier


func get_fire_rate() -> float:
	var fire_rate_count := UpgradeManager.get_peer_upgrade_count(
		player_input_synchronizer_component.get_multiplayer_authority(),
		"fire_rate"
	)
	
	return BASE_FIRE_RATE * (1 - (.1 * fire_rate_count))


func get_bullet_damage() -> int:
	var damage_count := UpgradeManager.get_peer_upgrade_count(
		player_input_synchronizer_component.get_multiplayer_authority(),
		"damage"
	)
	
	return BASE_DAMAGE_BULLET + damage_count


func set_display_name(incoming_name: String):
	display_name = incoming_name


func update_aim_position():
	var aim_vector = player_input_synchronizer_component.aim_vector
	var aim_position = weapon_root.global_position + aim_vector
	
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1, 1)
	weapon_root.look_at(aim_position)


func try_fire():
	if !fire_rate_timer.is_stopped():
		return
	
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.damage = get_bullet_damage()
	bullet.global_position = barrel_position.global_position
	bullet.source_peer_id = player_input_synchronizer_component.get_multiplayer_authority()
	bullet.start(player_input_synchronizer_component.aim_vector)
	get_parent().add_child(bullet, true)
	
	fire_rate_timer.wait_time = get_fire_rate()
	fire_rate_timer.start()
	
	play_fire_effects.rpc()


@rpc("authority", "call_local", "unreliable")
func play_fire_effects():
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("fire")
	
	var muzzle_flash: Node2D = muzzle_flash_scene.instantiate()
	muzzle_flash.global_position = barrel_position.global_position
	muzzle_flash.rotation = barrel_position.global_rotation
	get_parent().add_child(muzzle_flash)
	
	if player_input_synchronizer_component.is_multiplayer_authority():
		GameCamera.shake(1)


func kill():
	if !is_multiplayer_authority():
		push_error("Cannot call kill on non-server client")
		return
	
	_kill.rpc()
	await get_tree().create_timer(.5).timeout
	
	died.emit()
	queue_free()


@rpc("authority", "call_local", "reliable")
func _kill():
	is_dying = true
	player_input_synchronizer_component.public_visibility = false


func _on_died():
	kill()
