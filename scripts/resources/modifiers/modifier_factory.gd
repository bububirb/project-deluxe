class_name ModifierFactory extends Object

static func import_modifier(data: Dictionary) -> Modifier:
	var modifier: Modifier
	if data.class == "AdditiveDefenseModifier":
		modifier = AdditiveDefenseModifier.new()
		modifier.amount = data.amount
	else:
		modifier = Modifier.new()
	modifier.duration = data.duration
	modifier.icon_path = data.icon_path
	modifier.type = data.type
	return modifier
