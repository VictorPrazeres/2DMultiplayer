extends CharacterBody2D

@onready var hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	hurtbox.area_entered.connect(_on_area_entered)


func _on_area_entered(other_area: Area2D):
	if !is_multiplayer_authority():
		return
	if other_area.owner is Bullet:
		var bullet = other_area.owner as Bullet
		bullet.register_collision()
		print("collision")
