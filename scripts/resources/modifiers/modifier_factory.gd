class_name ModifierFactory extends Object

static func import_properties(modifier: Modifier, properties: Dictionary) -> Modifier:
	for property in properties.keys():
		modifier.set(property, properties[property])
	return modifier

static func import_modifier(data: Dictionary) -> Modifier:
	var modifier_path: String = data.resource_path
	var modifier: Modifier = load(modifier_path).new()
	var properties = data.duplicate()
	properties.erase("resource_path")
	import_properties(modifier, properties)
	return modifier

static func encode_modifiers(modifiers: Array[Modifier]) -> Array[Dictionary]:
	var encoded_modifiers: Array[Dictionary]
	for modifier: Modifier in modifiers:
		encoded_modifiers.append(modifier.export_modifier())
	return encoded_modifiers
