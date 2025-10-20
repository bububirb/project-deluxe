@tool
class_name ShipSprite extends PanelContainer

const SHIP_SPRITES_PATH: String = "res://assets/sprites/ships/"

@export var ship_name: String:
	set(new_ship_name):
		ship_name = new_ship_name
		for child in get_children():
			child.queue_free()
		var dir = DirAccess.open(SHIP_SPRITES_PATH)
		if dir.file_exists(ship_name + ".png"):
			var sprite: Texture2D = load(SHIP_SPRITES_PATH + ship_name + ".png")
			if sprite:
				var texture: TextureRect = TextureRect.new()
				texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				texture.texture = sprite
				texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(texture)
