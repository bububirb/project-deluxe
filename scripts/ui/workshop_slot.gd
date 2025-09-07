@tool
class_name WorkshopSlot extends PanelContainer

signal item_set(index: int, item: Item)

@export var workshop_item_scene: PackedScene
@export var item: Item:
	set(new_item):
		item = new_item
		item_set.emit(get_index(), item)
		for child in get_children():
			child.queue_free()
		if new_item:
			var workshop_item: WorkshopItem = workshop_item_scene.instantiate()
			workshop_item.item = item
			add_child(workshop_item)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("source") and data.has("item")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.source.item = item
	item = data.item
