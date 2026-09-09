class_name Player extends CharacterBody2D

var input_multiplayer_authority: int

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var weapon_root: Node2D = $WeaponRoot


func _ready() -> void:
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)


func _process(_delta: float) -> void:
	var aim_position = weapon_root.global_position + player_input_synchronizer_component.aim_vector
	weapon_root.look_at(aim_position)
	
	if is_multiplayer_authority():
		velocity = player_input_synchronizer_component.movement_vector * 100
		move_and_slide()
