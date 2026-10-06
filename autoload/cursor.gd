extends CanvasLayer

@onready var texture: Sprite2D = $Texture


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta: float) -> void:
	texture.global_position = texture.get_global_mouse_position()
