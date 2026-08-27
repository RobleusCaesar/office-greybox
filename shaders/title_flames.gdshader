shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;

float hash12(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p = p * 2.03 + vec2(17.1, 9.7);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	// Far-center fire at the end of 17th. Spare the 17TH ST sign and the wordmark.
	vec2 fire_c = vec2(0.50, 0.44);
	vec2 d = (uv - fire_c) / vec2(0.11, 0.15);
	float ellipse = 1.0 - clamp(dot(d, d), 0.0, 1.0);
	float spare_sign = 1.0 - smoothstep(0.70, 0.78, uv.x) * smoothstep(0.22, 0.72, uv.y);
	float spare_mark = smoothstep(0.20, 0.36, uv.x);
	vec3 base = texture(screen_tex, uv).rgb;
	float warmth = smoothstep(0.28, 0.62, base.r) * smoothstep(0.22, 0.08, base.b) * smoothstep(0.15, 0.45, base.g);
	float gate = ellipse * warmth * spare_sign * spare_mark;
	float n = fbm(uv * 9.0 + vec2(0.0, -TIME * 0.55));
	vec2 warp = vec2(
		(fbm(uv * 7.0 + TIME * 0.35) - 0.5) * 0.012,
		(n - 0.5) * 0.018
	) * gate;
	vec3 col = texture(screen_tex, clamp(uv + warp, vec2(0.0), vec2(1.0))).rgb;
	float pulse = 0.04 * sin(TIME * 3.2 + n * 6.28);
	col += vec3(0.18, 0.07, 0.02) * gate * (0.35 + pulse);
	COLOR = vec4(col, gate * 0.82);
}
