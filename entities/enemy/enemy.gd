extends CharacterBody2D

var current_health: int = 5

@onready var hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	hurtbox.area_entered.connect(_on_area_entered)


func handle_hit():
	current_health -= 1
	if current_health <= 0:
		queue_free()


func _on_area_entered(other_area: Area2D):
	if !is_multiplayer_authority():
		return
	if other_area.owner is Bullet:
		var bullet = other_area.owner as Bullet
		bullet.register_collision()
		handle_hit()
