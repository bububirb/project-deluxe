class_name SpeedBoost extends Node3D

# To be assigned by the deck
var stats: SpeedStats

var mode: Globals.ItemMode = Globals.ItemMode.USABLE
var cooldown: float = 0.0

func execute(ship: Ship) -> void:
	if cooldown > 0.0: return
	
	ship.speed_modifiers.append([stats.speed_boost, stats.duration])
	ship.nitro_particles.emitting = true
	cooldown = stats.cooldown
	ship.item_executed.emit(self)

func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown < 0.0:
		cooldown = 0.0
