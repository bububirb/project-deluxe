shader_type spatial;

// Set render modes: always draw depth and disable backface culling
render_mode depth_draw_always, cull_disabled;

// Uniforms for screen and depth textures
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

global uniform vec3 ocean_pos; // Global shader value for the player position
global uniform float wave_time;
global uniform float wave_amplitude;
global uniform float wave_scale;

uniform sampler2D wave_texture; // Noise wave texture
uniform sampler2D texture_normal; // Additional normal noise
uniform sampler2D texture_normal2; // Additional normal noise
uniform sampler2D wave_bump; // Normal bump map version of the noise wave texture
uniform vec2 wave_direction = vec2(0.5,-0.2); // Direction of wave 1
uniform vec2 wave_direction2 = vec2(-0.5,0.5); // Direction of wave 2

// Uniforms for time factor, noise zoom, and noise amplitude
uniform float time_factor = 2.5;
uniform float time_scale : hint_range(0.0, 2.0, 0.005) = 0.1; // Rate of movement multiplied by TIME

// Group uniforms for water colors
group_uniforms Water_colours;
uniform vec3 base_water_color:source_color;
uniform vec3 fresnel_water_color:source_color;
uniform vec4 deep_water_color : source_color;
uniform vec4 shallow_water_color : source_color;

// Group uniforms for depth-related parameters
group_uniforms Depth;
uniform float beers_law = 0.5;
uniform float depth_offset = -1.2;
uniform float near = 7.0;
uniform float far = 10000.0;

// Group uniforms for edge detection and foam effects
group_uniforms Edge_Detection;
uniform float edge_texture_scale = 3.5;
uniform float edge_texture_offset = 1.0;
uniform float edge_texture_speed = 0.1;
uniform float edge_foam_intensity = 2.0;
uniform float edge_fade_start = -3.0;
uniform float edge_fade_end = 6.6;
uniform sampler2D edge_foam_texture;

// Group uniforms for surface details
group_uniforms Surface_details;
uniform float metallic = 0.6;
uniform float roughness = 0.045;
uniform float uv_scale_text_a = 0.1;
uniform vec2 uv_speed_text_a = vec2(0.42, 0.3);
uniform float uv_scale_text_b = 0.6;
uniform vec2 uv_speed_text_b = vec2(0.15, 0.1);
uniform float uv_sampler_scale = 0.3;
uniform float blend_factor = 0.28;
uniform sampler2D normalmap_a;
uniform sampler2D normalmap_b;
uniform sampler2D uv_sampler;
uniform sampler2DArray caustic_sampler : hint_default_black;

varying vec3 world_pos;

// Fresnel function to calculate the reflection/refraction effect
float fresnel(float amount, vec3 normal, vec3 view) {
    return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

// Function to calculate edge depth
float edge(float depth) {
    depth = 2.0 * depth - 1.0;
    return near * far / (far - depth * (near - far));
}

// Function to calculate dynamic amplitude based on position and time
float dynamic_amplitude(vec2 pos, float time) {
    return 1.0 + 0.5 * sin(time + length(pos) * 0.1);
}

// Hash function for noise generation
float hash(vec2 p) {
    return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

// 2D noise function
float noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    vec2 a = vec2(1.0, 0.0);
    return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x),
               mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

// Fractional Brownian Motion (fBM) function for generating complex noise
float fbm(vec2 x) {
    float height = 0.0;
    float amplitude = 0.5;
    float frequency = 3.0;
    for (int i = 0; i < 6; i++) {
        height += noise(x * frequency) * amplitude;
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return height;
}

// Structure to hold wave results: displacement, tangent, binormal, and normal
struct WaveResult {
    vec3 displacement;
    vec3 tangent;
    vec3 binormal;
    vec3 normal;
};

float waveheight(vec2 offset, int mode) {
	float h1 = 0.0; // Wave1 texture height
	float h2 = 0.0; // Wave2 texture height
	float hmix = 0.0; // Wave texture heights mixed
	switch (mode) {
		case 0: // For getting only the Wave1 height
			h1 = texture(wave_texture, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction)/* * time_scale*/).r;
			return h1;
		case 1: // For getting only the Wave2 height
			h2 = texture(wave_texture, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction2)/* * time_scale*/).r;
			return h2;
		case 2: // For getting both Wave1 and Wave2 heights and getting the average
			h1 = texture(wave_texture, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction)/* * time_scale*/).r;
			h2 = texture(wave_texture, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction2)/* * time_scale*/).r;
			hmix = mix(h1, h2, 0.5);
			return (hmix - 0.5) * 2.0;
	}
}

vec3 waveheight_normal(vec2 offset, int mode) {
	vec3 h1 = vec3(0.0); // Wave1 texture height
	vec3 h2 = vec3(0.0); // Wave1 texture height
	vec3 hmix = vec3(0.0); // Wave texture heights mixed
	switch (mode) {
		case 0: // For getting only the Wave1 height
			h1 = texture(wave_bump, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction)).rgb;
			return h1;
		case 1: // For getting only the Wave2 height
			h2 = texture(wave_bump, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction2)).rgb;
			return h2;
		case 2: // For getting both Wave1 and Wave2 heights and getting the average
			h1 = texture(wave_bump, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction)).rgb;
			h2 = texture(wave_bump, (world_pos.xz + offset) / wave_scale + (wave_time * wave_direction2)).rgb;
			hmix = mix(h1, h2, 0.5);
			return hmix;
	}
}

// Varying variables to pass data from vertex to fragment shader
varying float height;
varying vec3 world_position;

// Vertex shader function
void vertex() {
    // Calculate time based on the global TIME variable and time_factor
    float time = TIME / time_factor;
    // Calculate wave displacement and normals
    // Apply wave displacement to the vertex position
    //VERTEX += waveResult.displacement;
	world_pos = VERTEX + ocean_pos;

	float height_mix = waveheight(vec2(0.0,0.0), 2);

	VERTEX.y += height_mix * wave_amplitude;

    // Store the height of the wave displacement
	height = height_mix * wave_amplitude;
    // height = waveResult.displacement.y;

    // Calculate world position of the vertex
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Fragment shader function
void fragment() {
    // Calculate UV coordinates based on world position
    vec2 uv = world_position.xz;
    // Sample UV offset texture
    vec2 uv_offset = texture(uv_sampler, uv * uv_sampler_scale).rg;

    // Calculate animated UV coordinates for normal maps
    vec2 animated_uv_a = (uv + uv_speed_text_a * TIME + uv_offset) * uv_scale_text_a;
    vec2 animated_uv_b = (uv + uv_speed_text_b * TIME + uv_offset) * uv_scale_text_b;
    // Sample normal maps
    vec3 normal_sample_a = texture(normalmap_a, animated_uv_a).rgb;
    vec3 normal_sample_b = texture(normalmap_b, animated_uv_b).rgb;

    // Normalize normal samples and combine them
    normal_sample_a = normalize(normal_sample_a * 2.0 - 1.0);
    normal_sample_b = normalize(normal_sample_b * 2.0 - 1.0);
    vec3 combined_normal = normalize(mix(normal_sample_a, normal_sample_b, blend_factor));

    // Sample depth texture
    float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    float depth = PROJECTION_MATRIX[3][2] / (depth_raw + PROJECTION_MATRIX[2][2]);

    // Calculate the distance from the camera to the water surface
    float camera_depth = INV_VIEW_MATRIX[3].y - world_position.y;
    if (camera_depth < 0.0) { // Camera is underwater
        // Map the depth to a range where deeper = positive beers_law, closer = negative beers_law
        float depth_factor = smoothstep(-10.0, 0.0, camera_depth); // Adjust -10.0 for the depth range
        ALPHA -= depth_factor * 0.3;
        }
    // Calculate depth blend factor using Beer's law
    float depth_blend = exp((depth + VERTEX.z + depth_offset) * -beers_law);
    depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
    float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);

    // Sample screen color and blend it with depth color
    vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
    vec3 depth_color = mix(shallow_water_color.rgb, deep_water_color.rgb, depth_blend_power);
    vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);

    // Calculate depth difference for edge detection
    float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
    float z_pos = edge(FRAGCOORD.z);
    float z_dif = z_depth - z_pos;

	// Time calculations for wave (normal map) movement
	vec2 time = (wave_time * wave_direction) * time_scale; // Movement rate of first wave
	vec2 time2 = (wave_time * wave_direction2) * time_scale; // Movement rate of second wave

    // Blend normal maps into one
	vec3 normal_blend = mix(texture(texture_normal,world_pos.xz / 10.0 + time / 10.0).rgb, texture(texture_normal2,world_pos.xz / 10.0 + time2 / 10.0).rgb, 0.5);

	// Blend Wave1 and Wave2 maps
	// vec3 wave_normal_blend = mix(texture(wave_bump, world_pos.xz / wave_scale + time).xyz,texture(wave_bump, world_pos.xz / wave_scale + time2).xyz,0.3);
	vec3 wave_normal_blend = waveheight_normal(vec2(0.0), 2);

    // Calculate fresnel effect
    float fresnel = fresnel(5.0, NORMAL, VIEW);
    vec3 surface_color = mix(base_water_color, fresnel_water_color, fresnel);

    // Calculate edge foam effect
    vec2 edge_uv = world_position.xz * edge_texture_scale + edge_texture_offset + TIME * edge_texture_speed;
    float edge_fade = smoothstep(edge_fade_start, edge_fade_end, z_dif);
    vec3 depth_color_adj = mix(texture(edge_foam_texture, edge_uv).rgb * edge_foam_intensity, color, edge_fade);

    vec3 final_color = surface_color;

    // Set the final color, metallic, roughness, and normal
    ALBEDO = clamp(final_color + depth_color_adj, vec3(0.0), vec3(1.0));
    METALLIC = metallic;
    ROUGHNESS = roughness;
	//NORMAL = perturbed_normal;
	NORMAL_MAP = mix(wave_normal_blend, normal_blend, 0.5);
}