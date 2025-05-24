class_name DamageDisplay extends VBoxContainer

func display_damage(value: int) -> void:
	var damage_label: DamageLabel = DamageLabel.new()
	damage_label.value = value
	add_child(damage_label)
