class_name AdditiveDefenseModifier extends Modifier

@export_range(-1.0, 1.0, 0.01) var amount: float = 0.25

func export_modifier() -> Dictionary:
	var export: Dictionary = {}
	export.class = "AdditiveDefenseModifier"
	export.duration = duration
	export.icon_path = icon_path
	export.type = type
	export.amount = amount
	return export
