@tool
class_name AdditiveDefenseModifier extends Modifier

const DEFENSE_DOWN_ICON_PATH: String = "res://assets/icons/modifiers/defense-down.svg"

@export_range(-1.0, 1.0, 0.01) var amount: float = -0.25

func _init() -> void:
	icon_path = DEFENSE_DOWN_ICON_PATH
	type = Globals.ModifierType.DEBUFF

func export_modifier() -> Dictionary:
	var export: Dictionary = export_properties()
	export.amount = amount
	return export
