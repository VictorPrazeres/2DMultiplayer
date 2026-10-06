class_name UpgradeOption extends Node2D

signal selected(index: int, for_peer_id: int)

var upgrade_index: int
var peer_id_filter: int = -1
var assigned_resource: UpgradeResource
var impact_particles_scene: PackedScene = preload("uid://wlikj6aovccc")
var ground_particles_scene: PackedScene = preload("uid://cxwbdae8auvd8")

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_flash_sprite_component: Sprite2D = $HitFlashSpriteComponent
@onready var player_detection_area: Area2D = $PlayerDetectionArea
@onready var info_container: VBoxContainer = $InfoContainer
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var hit_stream_player: AudioStreamPlayer = $HitStreamPlayer


func _ready() -> void:
	update_info()
	info_container.visible = false
	set_peer_id_filter(peer_id_filter)
	hurtbox_component.hit_by_hitbox.connect(_on_hit_by_hitbox)
	health_component.died.connect(_on_died)
	player_detection_area.area_entered.connect(_on_player_detection_area_entered)
	player_detection_area.area_exited.connect(_on_player_detection_area_exited)
	
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func play_in(delay: float = 0):
	hit_flash_sprite_component.scale = Vector2.ZERO
	
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func():
		animation_player.play("spawn")
	)


func set_peer_id_filter(new_peer_id: int):
	peer_id_filter = new_peer_id
	hurtbox_component.peer_id_filter = peer_id_filter
	hit_flash_sprite_component.peer_id_filter = peer_id_filter


func set_upgrade_index(index: int):
	upgrade_index = index


func set_upgrade_resource(upgrade_resource: UpgradeResource):
	assigned_resource = upgrade_resource
	update_info()


func update_info():
	if !is_instance_valid(title_label) || !is_instance_valid(description_label):
		return
	
	if assigned_resource == null:
		return
	
	title_label.text = assigned_resource.display_name
	description_label.text = assigned_resource.description


func kill():
	spawn_death_particles()
	queue_free()


func spawn_death_particles():
	var death_particles: Node2D = ground_particles_scene.instantiate()
	
	var background_node: Node = Main.background_mask
	if !is_instance_valid(background_node):
		background_node = get_parent()
	
	background_node.add_child(death_particles)
	death_particles.global_position = global_position


func despawn():
	animation_player.play("despawn")


@rpc("authority", "call_local")
func spawn_hit_effects():
	hit_stream_player.play()
	var hit_particles: Node2D = impact_particles_scene.instantiate()
	hit_particles.global_position = hurtbox_component.global_position
	get_parent().add_child(hit_particles)


@rpc("authority", "call_local", "reliable")
func kill_all(killed_name: String):
	var upgrade_option_nodes := get_tree().get_nodes_in_group("upgrade_option")
	
	for upgrade_option in upgrade_option_nodes:
		if upgrade_option.peer_id_filter == peer_id_filter:
			if upgrade_option.name == killed_name:
				upgrade_option.kill()
			else:
				upgrade_option.despawn()


func _on_died():
	selected.emit(upgrade_index, peer_id_filter)
	kill_all.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, name)
	
	if peer_id_filter != MultiplayerPeer.TARGET_PEER_SERVER:
		kill_all.rpc_id(peer_id_filter, name)


func _on_peer_disconnected(peer_id: int):
	if peer_id == peer_id_filter:
		despawn()


func _on_hit_by_hitbox():
	spawn_hit_effects.rpc_id(peer_id_filter)


func _on_player_detection_area_entered(_other_area: Area2D):
	info_container.visible = true


func _on_player_detection_area_exited(_other_are: Area2D):
	info_container.visible = false
