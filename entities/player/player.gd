extends CharacterBody2D


func _process(_delta: float) -> void:
	var movement_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = movement_vector * 100
	move_and_slide()
