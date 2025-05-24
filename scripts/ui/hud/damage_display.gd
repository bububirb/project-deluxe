class_name DamageDisplay extends VBoxContainer

const DAMAGE_LABEL_SETTINGS = preload("res://resources/label_settings/damage_label.tres")

func display_damage(value: int) -> void:
	var damage_label: DamageLabel = DamageLabel.new()
	damage_label.value = value
	damage_label.label_settings = DAMAGE_LABEL_SETTINGS
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(damage_label)
