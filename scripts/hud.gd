extends Control

@export var item_sprites: Control

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
