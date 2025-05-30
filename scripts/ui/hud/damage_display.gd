class_name DamageDisplay extends VBoxContainer

const DAMAGE_LABEL_SETTINGS = preload("res://resources/label_settings/damage_label.tres")

func display_damage(value: int, crit: bool = false, icon_path: String = "", id: int = -1) -> void:
	var damage_label: DamageLabel
	var icon: Texture2D
	if icon_path:
		icon = load(icon_path)
	if has_node(str(id)):
		damage_label = get_node(str(id))
		damage_label.value += value
		damage_label.crit = crit
	else:
		damage_label = DamageLabel.new()
		if id != -1:
			damage_label.name = str(id)
		damage_label.label_settings = DAMAGE_LABEL_SETTINGS
		damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		damage_label.size_flags_horizontal = Control.SIZE_SHRINK_END
		if icon:
			damage_label.icon = icon
		
		damage_label.value = value
		damage_label.crit = crit
		add_child(damage_label)
