shader_type canvas_item;

uniform float percent : hint_range(0.0, 1.0);

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 white_color = vec4(1.0, 1.0, 1.0, texture_color.a);
	COLOR = mix(texture_color, white_color, percent);
}
