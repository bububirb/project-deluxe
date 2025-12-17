extends Control

const LOADING_SCENE = "res://scenes/ui/loading_screen.tscn"
const LOBBY_SCENE = "res://scenes/ui/lobby.tscn"

@onready var server: VBoxContainer = $Controls/Server
@onready var client: VBoxContainer = $Controls/Client

func _ready() -> void:

	MultiplayerLobby.server_disconnected.connect(_on_multiplayer_lobby_server_disconnected)

	if not multiplayer.multiplayer_peer:
		MultiplayerLobby.create_game()
	
	if multiplayer.is_server():
		client.hide()
		server.show()
	else:
		server.hide()
		client.show()

func _on_start_button_pressed() -> void:
	MultiplayerLobby.status = MultiplayerLobby.ServerStatus.LOADING
	MultiplayerLobby.load_game.rpc(LOADING_SCENE)


func _on_ready_button_toggled(toggled_on: bool) -> void:
	MultiplayerLobby.set_player_is_ready.rpc(toggled_on)

func _on_back_button_pressed() -> void:
	return_to_lobby()

func _on_multiplayer_lobby_server_disconnected() -> void:
	return_to_lobby()

func return_to_lobby() -> void:
	MultiplayerLobby.remove_multiplayer_peer()
	get_tree().change_scene_to_file(LOBBY_SCENE)
