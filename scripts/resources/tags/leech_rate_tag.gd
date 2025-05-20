class_name LeechRateTag extends Tag

@export_range(0.0, 1.0, 0.01) var amount = 0.2

func export_tag() -> Dictionary:
	var export: Dictionary = export_properties()
	export.amount = amount
	return export
