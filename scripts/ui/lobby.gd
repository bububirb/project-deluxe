extends Control

const GAME_SCENE = "res://scenes/maps/game.tscn"
const LOADING_SCENE = "res://scenes/ui/loading_screen.tscn"
const PLAYER_SCENE = "res://scenes/drafts/tuggy_player.tscn"
const GAME_ROOM_SCENE = "res://scenes/ui/game_room.tscn"

@export var host_button: Button
@export var join_button: Button
@export var settings_button: Button
@export var settings_container: VBoxContainer
@export var name_input: LineEdit
@export var address_input: LineEdit
@export var port_input: LineEdit

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	name_input.text_changed.connect(_on_name_input_text_changed)
	address_input.text_changed.connect(_on_address_input_text_changed)
	port_input.text_changed.connect(_on_port_input_text_changed)
	
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
		if arguments.has("ip"):
			address_input.text = arguments["ip"]
		if OS.has_feature("client"):
			join_button.pressed.emit.call_deferred()
		else:
			host_button.pressed.emit.call_deferred()

	# Load config
	name_input.text = IO.config.name
	address_input.text = IO.config.join_address
	port_input.text = str(IO.config.port)

func _on_host_button_pressed() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(GAME_ROOM_SCENE)

func _on_join_button_pressed() -> void:
	var err = MultiplayerLobby.join_game(address_input.text, int(port_input.text))
	if not err:
		get_tree().change_scene_to_file(GAME_ROOM_SCENE)

func _on_settings_button_pressed() -> void:
	settings_container.visible = !settings_container.visible

func _on_name_input_text_changed(new_text: String) -> void:
	IO.config.name = new_text
	MultiplayerLobby.player_info.name = new_text

func _on_address_input_text_changed(new_text: String) -> void:
	IO.config.join_address = new_text

func _on_port_input_text_changed(new_text: String) -> void:
	IO.config.port = int(new_text)

