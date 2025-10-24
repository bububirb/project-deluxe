class_name Inventory extends HFlowContainer

@export var slot_scene: PackedScene
@export var item_container_scene: PackedScene
@export var items: Array[Item]:
	set(new_items):
		items = new_items
		update_item_slots()

func remove_item(item: Item) -> void:
	items.erase(item)
	update_item_slots()

func update_item_slots() -> void:
	for child: WorkshopSlot in get_children():
		child.queue_free()
	for item: Item in items:
		var slot: WorkshopSlot = slot_scene.instantiate()
		slot.item = item
		add_child(slot)
