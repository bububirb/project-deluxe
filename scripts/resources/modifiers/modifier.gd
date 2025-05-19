class_name Modifier extends Resource

@export var duration: float = 5.0
@export var scalable_duration: bool = true
@export_file("*.svg") var icon_path: String
@export var type: Globals.ModifierType = Globals.ModifierType.BUFF

func export_properties() -> Dictionary:
	var export: Dictionary = {}
	export.resource_path = get_script().resource_path
	export.duration = duration
	export.scalable_duration = scalable_duration
	export.icon_path = icon_path
	export.type = type
	return export

func export_modifier() -> Dictionary:
	var export: Dictionary = export_properties()
	return export
