shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_texture : repeat_enable, filter_linear;

group_uniforms depth;
uniform int layers : hint_range(0, 64, 1) = 8;
uniform float depth_amount = 1.0;
uniform float fade_amount : hint_range(0.0, 16.0, 0.01) = 1.0;

vec2 to_polar(vec2 uv) {
	uv = uv * 2.0 - 1.0;
	float radius = length(uv);
	float angle = atan(uv.x, uv.y);
	return vec2(angle / PI, radius) / 2.0;
}

float overlay(float a, float b){
	float limit = step(0.5, a);
	return mix(2.0 * a * b, 1.0 - 2.0 * (1.0 - a) * (1.0 - b), limit);
}

vec2 parallax(float depth, vec3 n, vec3 t, vec3 v) {
	vec3 normal = normalize(n);
	vec3 tangent = normalize(t);
	vec3 bitangent = cross(normal, tangent);
	vec3 view = normalize(v);
	vec3 view_tangent = vec3(dot(view, tangent), dot(view, bitangent), dot(view, normal));
	vec2 offset = (view_tangent.xy / max(view_tangent.z, 0.001)) * depth;
	offset = vec2(-offset.x, offset.y);
	
	return offset;
}

void fragment() {
	float value = 0.0;
	
	for(int i = 0; i < layers; i++){
		float t = float(i) / float(layers);
		float depth = t * depth_amount;
		
		vec2 circle_uv = UV + parallax(depth, NORMAL, TANGENT, VIEW);
		float circle = length(circle_uv * 2.0 - 1.0);
		
		circle = clamp((circle - 0.2) / 0.8, 0.0, 1.0);
		
		vec2 noise_uv = UV + parallax(depth, NORMAL, TANGENT, VIEW);
		noise_uv = to_polar(noise_uv);
		noise_uv.y += TIME * 0.1;
		noise_uv += t;
		float noise = texture(noise_texture, noise_uv).r;
		
		float layer_value = overlay(circle, noise);
		layer_value = step(0.5, layer_value);
		
		layer_value *= pow(1.0 - t, fade_amount);
		
		value = max(value, layer_value);
	}
	
	ALBEDO = vec3(value);
}
