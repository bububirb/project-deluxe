extends Control

@export var item_sprites: Control

func get_item(index: int) -> TextureRect:
	return item_sprites.get_child(index)

func get_item_sprite(index: int) -> TextureRect:  # Unused
	return get_item(index).get_node("TextureRect")
