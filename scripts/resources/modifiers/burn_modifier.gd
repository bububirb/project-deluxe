@tool
class_name BurnModifier extends Modifier

const BURN_ICON_PATH: String = "res://assets/icons/modifiers/burn.svg"

var burn_counter: float = 0.0
var player_id: int = -1

@export_range(0, 500, 1) var damage: int = 50
@export_range(0.1, 5.0, 0.05) var tick_duration: float = 1.0

func _init() -> void:
	icon_path = BURN_ICON_PATH
	type = Globals.ModifierType.DEBUFF

func export_modifier() -> Dictionary:
	var export: Dictionary = export_properties()
	export.damage = damage
	export.tick_duration = tick_duration
	return export
