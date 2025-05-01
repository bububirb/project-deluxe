extends PanelContainer

const BUFF_COLOR: Color = Color(0.2, 1.0, 0.2)
const DEBUFF_COLOR: Color = Color(1.0, 0.2, 0.2)

var modifier: Modifier:
	set(value):
		modifier = value
		icon = modifier.icon
		duration = modifier.duration
		type = modifier.type

var icon: Texture2D:
	set(value):
		icon = value
		icon_texture.texture = icon

var duration: float:
	set(value):
		duration = value
		modifier_duration.max_value = duration
		modifier_duration.value = modifier_duration.max_value

var type: Globals.ModifierType:
	set(value):
		type = value
		if type == Globals.ModifierType.BUFF:
			self_modulate = BUFF_COLOR
		elif type == Globals.ModifierType.DEBUFF:
			self_modulate = DEBUFF_COLOR

@onready var icon_texture: TextureRect = $IconTexture
@onready var modifier_duration: TextureProgressBar = $ModifierDuration

func _process(delta: float) -> void:
	modifier_duration.value -= delta
	if modifier_duration.value <= 0.0:
		queue_free()
