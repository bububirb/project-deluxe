extends VBoxContainer

@onready var players_list_container: VBoxContainer = $PlayersListContainer

func _ready() -> void:
	MultiplayerLobby.player_connected.connect(_on_multiplayer_lobby_player_connected)
	MultiplayerLobby.player_disconnected.connect(_on_multiplayer_lobby_player_disconnected)
	MultiplayerLobby.server_disconnected.connect(_on_multiplayer_lobby_server_disconnected)
	MultiplayerLobby.connection_reset.connect(_on_multiplayer_lobby_connection_reset)

func _on_multiplayer_lobby_player_connected(peer_id: int, player_info: Dictionary) -> void:
	var label: Label = Label.new()
	label.name = str(peer_id)
	label.text = "%s (%s)" % [player_info.name, peer_id]
	players_list_container.add_child(label)

func _on_multiplayer_lobby_player_disconnected(peer_id) -> void:
	players_list_container.get_node(str(peer_id)).queue_free()

func _on_multiplayer_lobby_server_disconnected() -> void:
	_clear_players()

func _on_multiplayer_lobby_connection_reset() -> void:
	_clear_players()

func _clear_players() -> void:
	for node in players_list_container.get_children():
		node.queue_free()
