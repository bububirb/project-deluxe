@tool
class_name DamageLabel extends Label

const DAMAGE_COLOR: Color = Color(1.0, 0.4, 0.4)
const HEALING_COLOR: Color = Color(0.4, 1.0, 0.4)
const LIFETIME: float = 4.0
const FADE_TIME: float = 0.1

@export var permanent: bool = false

@export var icon: Texture2D:
	set(new_icon):
		icon = new_icon
		queue_redraw()

@export var value: int = -1000:
	set(new_value):
		value = new_value
		text = str(abs(value))
		if value > 0:
			modulate = HEALING_COLOR
		else:
			modulate = DAMAGE_COLOR

var time: float = 0.0
var fading: bool = false

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and not permanent:
		time += delta
		if time >= LIFETIME - FADE_TIME and not fading:
			_fade()
		if time >= LIFETIME:
			queue_free()

func _draw() -> void:
	_draw_icon()

func _fade() -> void:
	fading = true
	create_tween().tween_property(self, "self_modulate", Color.TRANSPARENT, FADE_TIME)

func _draw_icon() -> void:
	if icon:
		draw_texture(icon, Vector2(-icon.get_size().x, size.y / 2.0 - icon.get_size().y / 2.0), modulate)
