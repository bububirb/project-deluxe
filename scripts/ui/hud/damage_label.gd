@tool
class_name DamageLabel extends Label

const DAMAGE_COLOR: Color = Color(1.0, 0.4, 0.4)
const HEALING_COLOR: Color = Color(0.4, 1.0, 0.4)
const LIFETIME: float = 4.0
const FADE_TIME: float = 0.1

@export var permanent: bool = false
var time: float = 0.0
var fading: bool = false

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
		if time >= LIFETIME - FADE_TIME and not fading:
			_fade()
		if time >= LIFETIME:
			queue_free()

func _fade() -> void:
	fading = true
	create_tween().tween_property(self, "self_modulate", Color.TRANSPARENT, FADE_TIME)
