@tool
class_name DamageLabel extends Label

const DAMAGE_COLOR: Color = Color(1.0, 0.4, 0.4)
const HEALING_COLOR: Color = Color(0.4, 1.0, 0.4)
const LIFETIME: float = 4.0
const FADE_TIME: float = 0.1

var crit_icon: Texture2D = preload("res://assets/icons/modifiers/crit.svg")
var icon_count: int = 0

@export var permanent: bool = false

@export var crit: bool = false:
	set(new_crit):
		crit = new_crit
		queue_redraw()
@export var icon: Texture2D:
	set(new_icon):
		icon = new_icon
		queue_redraw()

@export var value: int = -1000:
	set(new_value):
		value = new_value
		text = str(abs(value))
		time = 0.0
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
	_draw_icons()

func _fade() -> void:
	fading = true
	create_tween().tween_property(self, "self_modulate", Color.TRANSPARENT, FADE_TIME)

func _draw_icon(draw_icon: Texture2D, color: Color = Color.WHITE) -> void:
	icon_count += 1
	draw_texture(draw_icon, icon_offset(draw_icon) * icon_count, color)

func _draw_icons() -> void:
	icon_count = 0
	if icon:
		_draw_icon(icon, modulate)
	if crit:
		_draw_icon(crit_icon)

func icon_offset(icon: Texture2D) -> Vector2:
	return Vector2(-icon.get_size().x, size.y / 2.0 - icon.get_size().y / 2.0)
