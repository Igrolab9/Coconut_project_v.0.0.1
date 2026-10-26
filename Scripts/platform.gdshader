shader_type spatial;

// === ПАРАМЕТРЫ ВОЛН ===
uniform float patch_height : hint_range(0.0, 0.5) = 0.08;
uniform float patch_length : hint_range(0.5, 40.0) = 8.0;
uniform float patch_speed : hint_range(0.0, 5.0) = 0.5;

uniform float ripple_height : hint_range(0.0, 0.2) = 0.03;
uniform float ripple_freq : hint_range(0.01, 5.0) = 0.6;

// === ПАРАМЕТРЫ ТЕКСТУРЫ ===
uniform sampler2D water_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform float texture_scale : hint_range(0.1, 10.0) = 2.0;
uniform float uv_scroll_speed : hint_range(0.0, 2.0) = 0.15;

void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 pos = VERTEX;
	
	float time = TIME;

	// === ОКРУГЛЫЕ ВОЛНЫ (Gerstner-style) ===
	// Основная волна с более округлой формой
	float wave1 = sin(world.x * (TAU / patch_length) + time * patch_speed);
	float wave2 = sin(world.x * (TAU / patch_length) * 2.0 + time * patch_speed * 1.3) * 0.5;
	float wave3 = cos(world.x * (TAU / patch_length) * 0.5 + time * patch_speed * 0.7) * 0.3;
	
	// Комбинируем волны для более округлой формы
	float patch = wave1 + wave2 + wave3;
	pos.y += patch * patch_height;

	// === ОКРУГЛАЯ РЯБЬ ===
	// Многослойная рябь для естественности
	float ripple1 = sin(world.x * ripple_freq + time * 2.0);
	float ripple2 = sin(world.z * ripple_freq * 0.8 + time * 1.6);
	float ripple3 = sin((world.x + world.z) * ripple_freq * 1.2 + time * 1.8) * 0.6;
	float ripple4 = cos(world.x * ripple_freq * 1.5 + world.z * ripple_freq * 0.7 + time * 2.2) * 0.4;
	
	pos.y += (ripple1 + ripple2 + ripple3 + ripple4) * ripple_height * 0.25;

	VERTEX = pos;
}

void fragment() {
	vec2 scrolled_uv = UV * texture_scale;
	scrolled_uv.x += TIME * uv_scroll_speed;
	scrolled_uv.y += TIME * uv_scroll_speed * 0.5;

	vec4 tex_color = texture(water_tex, scrolled_uv);

	ALBEDO = tex_color.rgb;
	ROUGHNESS = 0.25;
	SPECULAR = 0.6;
}