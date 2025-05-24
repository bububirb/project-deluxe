@tool
class_name DamageLabel extends Label

const DAMAGE_COLOR = Color(1.0, 0.4, 0.4)
const HEALING_COLOR = Color(0.4, 1.0, 0.4)
const LABEL_SETTINGS = preload("res://resources/label_settings/damage_label.tres")

var lifetime: float = 20.0
var time: float = 0.0

@export var value: int = -1000:
	set(new_value):
		value = new_value
		text = str(abs(value))
		if value > 0:
			modulate = HEALING_COLOR
		else:
			modulate = DAMAGE_COLOR

func _init() -> void:
	label_settings = LABEL_SETTINGS
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		time += delta
	if time >= lifetime:
		queue_free()
