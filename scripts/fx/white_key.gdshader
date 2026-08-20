shader_type canvas_item;
render_mode unshaded;

uniform float white_threshold : hint_range(0.0, 1.0) = 0.90;
uniform float feather : hint_range(0.001, 0.3) = 0.09;

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	float brightest = max(max(texel.r, texel.g), texel.b);
	float darkest = min(min(texel.r, texel.g), texel.b);
	float saturation_hint = brightest - darkest;
	float near_white = smoothstep(white_threshold, min(1.0, white_threshold + feather), darkest);
	float neutral = 1.0 - smoothstep(0.04, 0.14, saturation_hint);
	float keyed_alpha = texel.a * (1.0 - near_white * neutral);
	COLOR = vec4(texel.rgb, keyed_alpha) * COLOR;
}

