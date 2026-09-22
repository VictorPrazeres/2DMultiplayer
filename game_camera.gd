class_name GameCamera extends Camera2D

const NOISE_GROWTH: float = 750
const SHAKE_DECAY_RATE: float = 10

static var instance: GameCamera

@export var noise_texture: FastNoiseLite
@export var shake_strength: float

var noise_offset_x: float
var noise_offset_y: float
var current_shake_percentage: float


func _ready() -> void:
	instance = self


func _process(delta: float) -> void:
	if current_shake_percentage == 0:
		return
	
	noise_offset_x += NOISE_GROWTH * delta
	noise_offset_y += NOISE_GROWTH * delta
	
	var offset_sample_x := noise_texture.get_noise_2d(noise_offset_x, 0)
	var offset_sample_y := noise_texture.get_noise_2d(0, noise_offset_y)
	
	offset = Vector2(offset_sample_x, offset_sample_y) * shake_strength * current_shake_percentage * current_shake_percentage
	
	current_shake_percentage = max(current_shake_percentage - (SHAKE_DECAY_RATE * delta), 0)


static func shake(shake_percent: float):
	instance.current_shake_percentage = clamp(shake_percent, 0, 1)
