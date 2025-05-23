class_name BurnModifier extends Modifier

@export_range(0, 500, 1) var damage: int = 50

func export_modifier() -> Dictionary:
	var export: Dictionary = export_properties()
	export.damage = damage
	return export
