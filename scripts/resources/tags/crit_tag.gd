class_name CritTag extends Tag

@export_range(0.0, 1.0, 0.01) var crit_chance = 0.25
@export_range(0.0, 4.0, 0.01) var crit_damage = 0.5

func export_tag() -> Dictionary:
	var export: Dictionary = export_properties()
	export.crit_chance = crit_chance
	export.crit_damage = crit_damage
	return export
