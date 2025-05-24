class_name BurnModifier extends Modifier

const BURN_TICK_DURATION: float = 1.0
var burn_counter: float = 0.0

@export_range(0, 500, 1) var damage: int = 50

func export_modifier() -> Dictionary:
	var export: Dictionary = export_properties()
	export.damage = damage
	return export
