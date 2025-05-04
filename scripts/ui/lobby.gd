extends Control

const GAME_SCENE = "res://scenes/maps/game.tscn"
const LOADING_SCENE = "res://scenes/ui/loading_screen.tscn"
const PLAYER_SCENE = "res://scenes/drafts/tuggy_player.tscn"

@onready var host_button: Button = $CenterContainer/PanelContainer/MarginContainer/LobbyContainer/HBoxContainer/HostButton
@onready var join_button: Button = $CenterContainer/PanelContainer/MarginContainer/LobbyContainer/HBoxContainer/JoinButton
@onready var start_button: Button = $CenterContainer/PanelContainer/MarginContainer/HostingContainer/StartButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/HostingContainer/TitleBar/BackButton
@onready var exit_button: Button = $CenterContainer/PanelContainer/MarginContainer/JoiningContainer/ExitButton
@onready var players_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/HostingContainer/PlayersContainer
@onready var lobby_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LobbyContainer
@onready var hosting_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/HostingContainer
@onready var joining_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/JoiningContainer
@onready var name_input: LineEdit = $CenterContainer/PanelContainer/MarginContainer/LobbyContainer/HBoxContainer2/NameInput
@onready var address_input: LineEdit = $CenterContainer/PanelContainer/MarginContainer/LobbyContainer/HBoxContainer3/AddressInput
@onready var ip_label: RichTextLabel = $CenterContainer/PanelContainer/MarginContainer/HostingContainer/IPContainer/IPLabel

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	name_input.text_changed.connect(_on_name_input_text_changed)
	
	MultiplayerLobby.server_disconnected.connect(_on_multiplayer_lobby_server_disconnected)
	
	if DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN):
		ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", true)
	
	if OS.has_feature("headless"):
		var arguments = {}
		for argument in OS.get_cmdline_args():
			if argument.contains("="):
				var key_value = argument.split("=")
				arguments[key_value[0].trim_prefix("--")] = key_value[1]
			else:
				# Options without an argument will be present in the dictionary,
				# with the value set to an empty string.
				arguments[argument.trim_prefix("--")] = ""
		if arguments["ip"]:
			address_input.text = arguments["ip"]
		join_button.pressed.emit()

func _on_host_button_pressed() -> void:
	MultiplayerLobby.create_game()
	lobby_container.hide()
	hosting_container.show()
	_update_ip_label()

func _update_ip_label() -> void:
	var addresses = IP.get_local_addresses()
	addresses.remove_at(IP.get_local_addresses().find(MultiplayerLobby.DEFAULT_SERVER_IP))
	ip_label.text = "\n".join(addresses)

func _on_join_button_pressed() -> void:
	var err = MultiplayerLobby.join_game(address_input.text)
	if not err:
		lobby_container.hide()
		joining_container.show()

func _on_back_button_pressed() -> void:
	MultiplayerLobby.remove_multiplayer_peer()
	hosting_container.hide()
	lobby_container.show()

func _on_exit_button_pressed() -> void:
	MultiplayerLobby.remove_multiplayer_peer()
	joining_container.hide()
	lobby_container.show()

func _on_start_button_pressed() -> void:
	MultiplayerLobby.status = MultiplayerLobby.ServerStatus.LOADING
	MultiplayerLobby.load_game.rpc(LOADING_SCENE)

func _on_name_input_text_changed(new_text: String) -> void:
	MultiplayerLobby.player_info.name = new_text

func _on_multiplayer_lobby_server_disconnected() -> void:
	joining_container.hide()
	lobby_container.show()
