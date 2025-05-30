class_name DamageDisplay extends VBoxContainer

const DAMAGE_LABEL_SETTINGS = preload("res://resources/label_settings/damage_label.tres")

func display_damage(value: int, icon_path: String = "") -> void:
	var damage_label: DamageLabel = DamageLabel.new()
	var icon: Texture2D
	if icon_path:
		icon = load(icon_path)
		damage_label.icon = icon
	damage_label.value = value
	damage_label.label_settings = DAMAGE_LABEL_SETTINGS
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	damage_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	add_child(damage_label)
