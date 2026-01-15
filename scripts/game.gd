extends Node3D

@onready var player: Node3D# = $Player
@onready var spawn_positions: Node3D = $SpawnPositions

func _ready() -> void:
	# Preconfigure game.
	if DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN):
		ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	MultiplayerLobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	
	MultiplayerLobby.server_disconnected.connect(_on_multiplayer_lobby_server_disconnected)

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	GameplayServer.start.rpc()
	for i in MultiplayerLobby.players.keys().size():
		var peer_id: int = MultiplayerLobby.players.keys()[i]
		add_player(peer_id, i)
	BuoyancySolver.reset_wave_time.rpc()
	pass

func add_player(peer_id: int, spawn_position: int) -> void:
	var ship_name: String = MultiplayerLobby.players[peer_id].ship
	var player_scene: PackedScene = load(Globals.PLAYER_SCENES_DIRECTORY + "/" + ship_name + "_player.tscn")
	var player_node: Node3D = player_scene.instantiate()
	player_node.name = str(peer_id)
	add_child(player_node)
	if multiplayer.is_server():
		player_node.set_spawn.rpc(spawn_positions.get_child(spawn_position).transform)

func _on_multiplayer_lobby_server_disconnected() -> void:
	GameplayServer.stop()
	get_tree().change_scene_to_packed(Globals.GAME_ROOM_SCENE)
