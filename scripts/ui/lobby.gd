extends Control

const GAME_SCENE = "res://scenes/maps/map_01.tscn"

@onready var host_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HostButton
@onready var start_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/StartButton
@onready var join_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/JoinButton
@onready var players_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlayersContainer

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	
	MultiplayerLobby.player_connected.connect(_on_multiplayer_lobby_player_connected)

func _on_host_button_pressed() -> void:
	MultiplayerLobby.create_game()
	host_button.hide()
	join_button.hide()
	start_button.show()

func _on_join_button_pressed() -> void:
	MultiplayerLobby.join_game()

func _on_start_button_pressed() -> void:
	MultiplayerLobby.load_game.rpc(GAME_SCENE)

func _on_multiplayer_lobby_player_connected(peer_id, player_info) -> void:
	var label: Label = Label.new()
	label.text = str(peer_id)
	players_container.add_child(label)
