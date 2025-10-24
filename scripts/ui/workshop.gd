extends PanelContainer

@export var deck: Control
@export var inventory: Control

func _ready() -> void:
	if MultiplayerLobby.players:
		var player_deck: Array[String]
		player_deck.assign(MultiplayerLobby.players[multiplayer.get_unique_id()].deck.values())
		for i in player_deck.size():
			set_item_slot(i, player_deck[i])
	for workshop_slot: WorkshopSlot in deck.get_children():
		workshop_slot.item_set.connect(_on_workshop_slot_item_set)

func _on_workshop_slot_item_set(index: int, item: Item) -> void:
	var item_name: String
	if item:
		item_name = item.item_name
	MultiplayerLobby.set_player_deck_item.rpc(index, item_name)

func set_item_slot(index: int, item_name: String) -> void:
	var item: Item = load("res://resources/items/" + item_name + ".tres")
	deck.get_child(index).item = item
	inventory.remove_item(item)
