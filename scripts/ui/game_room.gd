extends Control

const LOADING_SCENE = "res://scenes/ui/loading_screen.tscn"
const LOBBY_SCENE = "res://scenes/ui/lobby.tscn"

@onready var server: VBoxContainer = $Controls/Server
@onready var client: VBoxContainer = $Controls/Client

func _ready() -> void:
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

#TODO: Implement client ready functionality

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(LOBBY_SCENE)
