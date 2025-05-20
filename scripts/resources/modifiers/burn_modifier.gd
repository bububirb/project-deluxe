class_name BurnModifier extends Modifier

@export_range(0.0, 500.0, 0.1) var damage: float = 50.0

func export_modifier() -> Dictionary:
	var export: Dictionary = export_properties()
	export.damage = damage
	return export
