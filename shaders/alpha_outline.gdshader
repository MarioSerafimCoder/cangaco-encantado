shader_type canvas_item;
render_mode unshaded;

uniform float outline_width : hint_range(1.0, 16.0) = 11.0;
uniform vec4 outline_color : source_color = vec4(1.0, 0.56, 0.18, 1.0);

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	vec2 step_size = TEXTURE_PIXEL_SIZE * outline_width;
	float neighbor = 0.0;
	neighbor = max(neighbor, texture(TEXTURE, UV + vec2(step_size.x, 0.0)).a);
	neighbor = max(neighbor, texture(TEXTURE, UV - vec2(step_size.x, 0.0)).a);
	neighbor = max(neighbor, texture(TEXTURE, UV + vec2(0.0, step_size.y)).a);
	neighbor = max(neighbor, texture(TEXTURE, UV - vec2(0.0, step_size.y)).a);
	neighbor = max(neighbor, texture(TEXTURE, UV + step_size).a);
	neighbor = max(neighbor, texture(TEXTURE, UV - step_size).a);
	neighbor = max(neighbor, texture(TEXTURE, UV + vec2(step_size.x, -step_size.y)).a);
	neighbor = max(neighbor, texture(TEXTURE, UV + vec2(-step_size.x, step_size.y)).a);
	vec4 base_color = texel * COLOR;
	if (texel.a < 0.18 && neighbor > 0.28) {
		base_color = vec4(outline_color.rgb, outline_color.a * neighbor) * COLOR;
	}
	COLOR = base_color;
}
