@tool
class_name SpeedModifier extends Modifier

const SPEED_UP_ICON_PATH: String = "res://assets/icons/modifiers/speed_up.svg"

@export_range(0.0, 10.0, 0.01) var speed_multiplier: float = 1.5

func _init() -> void:
	icon_path = SPEED_UP_ICON_PATH
	type = Globals.ModifierType.BUFF
