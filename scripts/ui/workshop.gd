extends PanelContainer

@export var deck: Control

func _ready() -> void:
	for workshop_slot: WorkshopSlot in deck.get_children():
		workshop_slot.item_set.connect(_on_workshop_slot_item_set)

func _on_workshop_slot_item_set(index: int, item: Item) -> void:
	var item_name: String
	if item:
		item_name = item.item_name
	var new_player_info = MultiplayerLobby.player_info.duplicate()
	new_player_info.deck[index] = item_name
	MultiplayerLobby.player_info = new_player_info
