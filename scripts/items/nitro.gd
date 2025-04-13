class_name Nitro extends Node3D

var stats: SpeedStats # To be assigned by the deck

func execute(ship: Ship) -> void:
	ship.acceleration += stats.speed_boost
