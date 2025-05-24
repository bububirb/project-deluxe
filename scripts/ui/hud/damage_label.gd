@tool
class_name DamageLabel extends Label

const DAMAGE_COLOR = Color(1.0, 0.4, 0.4)
const HEALING_COLOR = Color(0.4, 1.0, 0.4)

@export var permanent: bool = false
var lifetime: float = 4.0
var time: float = 0.0

@export var value: int = -1000:
	set(new_value):
		value = new_value
		text = str(abs(value))
		if value > 0:
			modulate = HEALING_COLOR
		else:
			modulate = DAMAGE_COLOR

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and not permanent:
		time += delta
	if time >= lifetime:
		queue_free()
