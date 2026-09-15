shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV + vec2(.04 * TIME, .02 * TIME));
	COLOR = color;
}