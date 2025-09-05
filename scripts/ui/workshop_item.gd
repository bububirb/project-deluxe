@tool
class_name WorkshopItem extends PanelContainer

@export var sprite: TextureRect

@export var item: Item:
	set(new_item):
		item = new_item
		if sprite:
			if item:
				sprite.texture = item.sprite
			else:
				sprite.texture = null

func _get_drag_data(drag_position: Vector2) -> Dictionary:
	set_drag_preview(_make_drag_preview(drag_position))
	return { "source": get_parent(), "item": item }

func _make_drag_preview(drag_position: Vector2) -> Control:
	var preview = Control.new()
	var preview_item: Control = self.duplicate()
	preview.add_child(preview_item)
	preview_item.position = -drag_position
	return preview
