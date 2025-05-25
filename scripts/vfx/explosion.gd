extends Node3D

@onready var fire_particles: GPUParticles3D = $FireParticles
@onready var ember_patricles: GPUParticles3D = $EmberPatricles

func start() -> void:
	fire_particles.emitting = true
	ember_patricles.emitting = true
