class_name Modifier extends Resource

@export var duration: float = 5.0
@export_file("*.svg") var icon_path: String
@export var type: Globals.ModifierType = Globals.ModifierType.BUFF

func export_modifier() -> Dictionary:
	var export: Dictionary = {}
	export.class = "Modifier"
	export.duration = duration
	export.icon_path = icon_path
	export.type = type
	return export
