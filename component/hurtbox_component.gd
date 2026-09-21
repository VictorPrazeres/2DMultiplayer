class_name HurtboxComponent extends Area2D

signal hit_by_hitbox

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _handle_hit(hitbox_component: HitboxComponent):
	hitbox_component.register_hurtbox_hit(self)
	health_component.damage(hitbox_component.damage)
	hit_by_hitbox.emit()


func _on_area_entered(other_area: Area2D):
	if !is_multiplayer_authority() || other_area is not HitboxComponent:
		return
	
	_handle_hit.call_deferred(other_area)
