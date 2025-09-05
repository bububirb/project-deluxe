extends HFlowContainer

@export var slot_scene: PackedScene
@export var item_container_scene: PackedScene
@export var items: Array[Item]

func _ready() -> void:
	for item: Item in items:
		var slot: WorkshopSlot = slot_scene.instantiate()
		slot.item = item
		add_child(slot)
