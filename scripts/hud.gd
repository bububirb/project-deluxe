extends Control

@export var item_sprites: Control
@export var vitals_overlay: TextureRect

func get_item(index: int) -> TextureRect:
	return item_sprites.get_child(index)

func get_item_sprite(index: int) -> TextureRect:  # Unused
	return get_item(index).get_node("TextureRect")

func get_item_cooldown(index: int) -> ProgressBar:
	return get_item(index).get_node("Cooldown")

func _ready() -> void:
	for item_sprite in item_sprites.get_children():
		var item_cooldown: ProgressBar = item_sprite.get_node("Cooldown")
		item_cooldown.value = item_cooldown.max_value

func trigger_health_effect(_health: int = 0):
	var tween_1: PropertyTweener = create_tween().tween_property(vitals_overlay, "modulate", Color.RED, 0.05)
	await tween_1.finished
	var _tween_2: PropertyTweener = create_tween().tween_property(vitals_overlay, "modulate", Color.TRANSPARENT, 0.8)
