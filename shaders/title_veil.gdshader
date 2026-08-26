shader_type canvas_item;
render_mode unshaded;

void fragment() {
	float x = SCREEN_UV.x;
	float y = SCREEN_UV.y;
	float h = pow(clamp(1.0 - x / 0.42, 0.0, 1.0), 1.35);
	float fire_zone = smoothstep(0.50, 0.86, y) * smoothstep(0.44, 0.14, x);
	float a = h * 0.44 * (1.0 - fire_zone * 0.58);
	COLOR = vec4(0.012, 0.008, 0.006, a);
}
