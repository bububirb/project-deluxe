class_name Tag extends Resource

func export_properties() -> Dictionary:
	var export: Dictionary = {}
	export.resource_path = get_script().resource_path
	return export

func export_tag() -> Dictionary:
	var export: Dictionary = export_properties()
	return export
