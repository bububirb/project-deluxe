extends PanelContainer

@export var deck: Control

func _ready() -> void:
	for workshop_slot: WorkshopSlot in deck.get_children():
		workshop_slot.item_set.connect(_on_workshop_slot_item_set)

func _on_workshop_slot_item_set(index: int, item: Item) -> void:
	var item_name: String
	if item:
		item_name = item.item_name
	MultiplayerLobby.set_player_deck_item.rpc(index, item_name)
