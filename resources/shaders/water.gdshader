shader_type spatial;
render_mode depth_prepass_alpha;

group_uniforms engine_textures;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

group_uniforms shared_constraints;
global uniform vec3 ocean_pos; // Global shader value for the player position
global uniform float wave_time;
global uniform float wave_amplitude;
global uniform float wave_scale;

group_uniforms material_and_colour;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
//colours
uniform vec3 color_deep : source_color = vec3(0.11,0.29,0.33); // Deep depth color
uniform vec3 color_shallow : source_color = vec3(0.0,0.47,0.76); // Shallow depth color

uniform float beers_law = 2.0; // Beer's law application
uniform float depth_offset = 1.5; // Offset
uniform float edge_scale = 0.3;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color : source_color = vec3(1.0,1.0,1.0);

group_uniforms maps_and_noise;
uniform sampler2D wave; // Noise wave texture
uniform sampler2D wave_bump; // Normal bump map version of the noise wave texture
uniform sampler2D texture_normal; // Additional normal noise
uniform sampler2D texture_normal2; // Additional normal noise

group_uniforms movement_settings;
uniform vec2 wave_direction = vec2(0.5,-0.2); // Direction of wave 1
uniform vec2 wave_direction2 = vec2(-0.5,0.5); // Direction of wave 2
uniform float time_scale : hint_range(0.0, 2.0, 0.005) = 0.1; // Rate of movement multiplied by TIME
uniform float noise_scale = 20.0; // Scale of the wave noise texture
uniform float height_scale = 2.0; // Mulitply the normal height values


// Varying variables
varying float height;
varying vec3 world_pos;
varying float vertex_distance;
varying float vertex_distance_clamped;
varying vec2 vertex_pos;

//returns a high value for grazing angles
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float edge(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

//returns height of mesh at certain offset (mode variable to choose which wave
float waveheight(vec2 offset, int mode) {
	float h1 = 0.0; // Wave1 texture height
	float h2 = 0.0; // Wave2 texture height
	float hmix = 0.0; // Wave texture heights mixed
	switch (mode) {
		case 0: // For getting only the Wave1 height
			h1 = texture(wave, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction)/* * time_scale*/).r;
			return h1;
		case 1: // For getting only the Wave2 height
			h2 = texture(wave, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction2)/* * time_scale*/).r;
			return h2;
		case 2: // For getting both Wave1 and Wave2 heights and getting the average
			h1 = texture(wave, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction)/* * time_scale*/).r;
			h2 = texture(wave, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction2)/* * time_scale*/).r;
			hmix = mix(h1, h2, 0.5);
			return (hmix - 0.5) * 2.0;
	}
}
//Adjust vertex height according to waveheight function
void vertex() {
	world_pos = VERTEX;

	float height_mix = waveheight(vec2(0.0,0.0), 2);

	VERTEX.y += height_mix * wave_amplitude;
}

void fragment() {
	//TIME AND POSITION RELIANT CALCULATIONS DO NOT MODIFY
	// Movement rate of first wave
	vec2 time = (wave_time * wave_direction) * time_scale;
	// Movement rate of second wave
	vec2 time2 = (wave_time * wave_direction2) * time_scale;
	// Blend normal maps into one
	vec3 normal_blend = mix(texture(texture_normal,world_pos.xz / 10.0 + time / 10.0).rgb, texture(texture_normal2,world_pos.xz / 10.0 + time2 / 10.0).rgb, 0.5);
	// Blend Wave1 and Wave2 maps
	vec3 wave_normal_blend = mix(texture(wave_bump, world_pos.xz / wave_scale + time).xyz,texture(wave_bump, world_pos.xz / wave_scale + time2).xyz,0.3);

	// Depth calculation
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth+VERTEX.z + depth_offset) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);

	// Retrieving depth color and applying the deep and shallow colors
	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);

	// Getting edge depth calc
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;

	//Worldspace position of fragment
	float depth1 = FRAGCOORD.z;
	vec2 frag_ndc = ((FRAGCOORD.xy / VIEWPORT_SIZE) * 2.0) - 1.0;
	vec4 frag_view_space_position = INV_PROJECTION_MATRIX * vec4(frag_ndc, depth1, 1.0);
	frag_view_space_position /= frag_view_space_position.w;
	vec4 frag_world_space = INV_VIEW_MATRIX * frag_view_space_position;


	// Calculate Fresnel
	float fresnel = clamp(fresnel(10.0, NORMAL, VIEW),0.0,1.0);
	float shallow_influence = clamp(frag_world_space.y - (fresnel),0.0,1.0);

	//ALBEDO = mix(color_deep, color_shallow,shallow_influence);
	ALBEDO = vec3(shallow_influence);
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	//NORMAL_MAP = mix(wave_normal_blend, normal_blend, 0.5);
	//SPECULAR = wave_normal_blend.r;
}