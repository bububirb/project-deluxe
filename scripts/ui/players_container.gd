extends VBoxContainer

@export var item_sprite: PackedScene

@onready var players_list_container: VBoxContainer = $PlayersListContainer

func _ready() -> void:
	MultiplayerLobby.player_connected.connect(_on_multiplayer_lobby_player_connected)
	MultiplayerLobby.player_disconnected.connect(_on_multiplayer_lobby_player_disconnected)
	MultiplayerLobby.server_disconnected.connect(_on_multiplayer_lobby_server_disconnected)
	MultiplayerLobby.connection_reset.connect(_on_multiplayer_lobby_connection_reset)
	MultiplayerLobby.player_info_updated.connect(_on_multiplayer_lobby_player_info_updated)
	
	if multiplayer:
		for peer_id in MultiplayerLobby.players.keys():
			_add_player(peer_id, MultiplayerLobby.players[peer_id])

func _on_multiplayer_lobby_player_connected(peer_id: int, player_info: Dictionary) -> void:
	_add_player(peer_id, player_info)

func _on_multiplayer_lobby_player_disconnected(peer_id) -> void:
	players_list_container.get_node(str(peer_id)).queue_free()

func _on_multiplayer_lobby_server_disconnected() -> void:
	_clear_players()

func _on_multiplayer_lobby_connection_reset() -> void:
	_clear_players()

func _on_multiplayer_lobby_player_info_updated(peer_id, player_info) -> void:
	if multiplayer.is_server():
		update_player_deck.rpc(peer_id, player_info)

func _add_player(peer_id: int, player_info: Dictionary) -> void:
	var player: HBoxContainer = HBoxContainer.new()
	player.name = str(peer_id)
	var label: Label = Label.new()
	label.text = "%s (ID: %s)" % [player_info.name, peer_id]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player.add_child(label)
	for sprite: ItemSprite in _make_player_deck(player_info):
		player.add_child(sprite)
	players_list_container.add_child(player)

func _make_player_deck(player_info: Dictionary) -> Array[ItemSprite]:
	var sprites: Array[ItemSprite]
	for item in player_info.deck.values():
		var sprite: ItemSprite = item_sprite.instantiate()
		sprite.item_name = item
		sprites.append(sprite)
	return sprites

@rpc("authority", "call_local", "reliable")
func update_player_deck(peer_id: int, player_info: Dictionary) -> void:
	var player: Control = _get_player(peer_id)
	for child in player.get_children():
		if child is ItemSprite:
			child.queue_free()
	for sprite: ItemSprite in _make_player_deck(player_info):
		player.add_child(sprite)

func _get_player(peer_id: int) -> Control:
	return players_list_container.get_node(str(peer_id))

func _clear_players() -> void:
	for node in players_list_container.get_children():
		node.queue_free()
