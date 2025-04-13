class_name Nitro extends Node3D

var stats: SpeedStats # To be assigned by the deck

func execute(ship: Ship) -> void:
	ship.speed_modifiers.append([stats.speed_boost, stats.duration])
	ship.nitro_particles.emitting = true
