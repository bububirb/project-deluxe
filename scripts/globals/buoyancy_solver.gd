@tool
extends Node

const WAVE_SPEED: float = 0.1
const WAVE_SCALE: float = 50.0
const WAVE_AMPLITUDE: float = 1.0

const WAVE_DIRECRION_1 : Vector2 = Vector2(0.5, -0.2)
const WAVE_DIRECRION_2 : Vector2 = Vector2(-0.5, 0.5)

const BUOYANCY: float = 5.0
const DAMPING: float = 0.95

var WAVE_RESOLUTION: int = 512
var wave_noise: NoiseTexture2D = load("res://resources/noise_texture/wave.tres")
var wave_texture: Image

var wave_time: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("wave_scale", WAVE_SCALE)
	RenderingServer.global_shader_parameter_set("wave_amplitude", WAVE_AMPLITUDE)
	await wave_noise.changed
	wave_texture = wave_noise.get_image()

func _process(delta: float) -> void:
	wave_time += delta * WAVE_SPEED
	RenderingServer.global_shader_parameter_set("wave_time", wave_time)

func wave(position: Vector2, direction: Vector2, scale: float, time: float):
	var frequency: float = scale * WAVE_SCALE
	return (sin((position + direction * time).x * frequency) + cos((position + direction * time).y * frequency)) * WAVE_AMPLITUDE

func waveheight(position: Vector2):
	var h1: float = 0.0
	var h2: float = 0.0
	var hmix: float = 0.0
	
	var sample_position_1: Vector2 = ((position) / WAVE_SCALE + (wave_time * WAVE_DIRECRION_1)) * WAVE_RESOLUTION
	var sample_position_2: Vector2 = ((position) / WAVE_SCALE + (wave_time * WAVE_DIRECRION_2)) * WAVE_RESOLUTION
	var sample_position_1_x: float = wrapf(sample_position_1.x, 0, WAVE_RESOLUTION - 1)
	var sample_position_1_y: float = wrapf(sample_position_1.y, 0, WAVE_RESOLUTION - 1)
	var sample_position_2_x: float = wrapf(sample_position_2.x, 0, WAVE_RESOLUTION - 1)
	var sample_position_2_y: float = wrapf(sample_position_2.y, 0, WAVE_RESOLUTION - 1)
	sample_position_1 = Vector2(sample_position_1_x, sample_position_1_y)
	sample_position_2 = Vector2(sample_position_2_x, sample_position_2_y)
	
	h1 = wave_texture.get_pixelv(sample_position_1).r
	h2 = wave_texture.get_pixelv(sample_position_2).r
	hmix = lerp(h1, h2, 0.5);
	return (hmix - 0.5) * 2.0 * WAVE_AMPLITUDE;

func height(position: Vector3) -> float:
	var position_xz: Vector2 = Vector2(position.x, position.z)
	var h: float = 0.0
	
	if wave_texture:
		h += waveheight(position_xz)
	return h

func get_slope(position: Vector3, delta: float) -> Vector3:
	var slope_x = (height(position + Vector3(delta, 0.0, 0.0)) - height(position + Vector3(-delta, 0.0, 0.0))) / (2.0 * delta)
	var slope_y = (height(position + Vector3(0.0, 0.0, delta)) - height(position + Vector3(0.0, 0.0, -delta))) / (2.0 * delta)
	return Vector3(slope_x, slope_y, 0)

func get_buoyancy_force(position, delta) -> float:
	var relative_height: float = height(position) - position.y
	#if relative_height > 0:
		#return gravity * delta
	#else:
	return gravity * relative_height * BUOYANCY * delta
