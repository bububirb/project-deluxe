@tool
class_name ItemSprite extends PanelContainer

const ITEMS_PATH: String = "res://resources/items/"

@export var item_name: String:
	set(new_item_name):
		item_name = new_item_name
		for child in get_children():
			child.queue_free()
		if new_item_name:
			var item: Item = load(ITEMS_PATH + item_name + ".tres")
			if item:
				var sprite: Texture2D = item.sprite
				var texture: TextureRect = TextureRect.new()
				texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				texture.texture = sprite
				add_child(texture)
