class_name SpeedBoost extends Node3D

# To be assigned by the deck
var mode: Globals.ItemMode
var stats: SpeedStats

func execute(ship: Ship) -> void:
	ship.speed_modifiers.append([stats.speed_boost, stats.duration])
	ship.nitro_particles.emitting = true
