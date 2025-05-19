class_name AdditiveDefenseModifier extends Modifier

@export_range(-1.0, 1.0, 0.01) var amount: float = 0.25

func export_modifier() -> Dictionary:
	var export: Dictionary = export_properties()
	export.amount = amount
	return export
