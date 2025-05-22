extends Node3D

@export var player_scene: PackedScene

@onready var player: Node3D# = $Player
@onready var spawn_positions: Node3D = $SpawnPositions

func _ready() -> void:
	# Preconfigure game.
	if DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN):
		ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	MultiplayerLobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	
	#player.ship.item_selected.connect(_on_ship_item_selected)
	#player.ship.item_executed.connect(_on_ship_item_executed)
	
	#for item: Node in player.ship.item_instancer.get_children():
	#	var item_index = item.get_index()
	#	hud.get_item_cooldown(item_index).max_value = item.stats.cooldown + 1.0

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	GameplayServer.start.rpc()
	for i in MultiplayerLobby.players.keys().size():
		var peer_id: int = MultiplayerLobby.players.keys()[i]
		add_player(peer_id, i)
	await get_tree().create_timer(0.5)
	BuoyancySolver.reset_wave_time.rpc()
	pass

func add_player(peer_id: int, spawn_position: int) -> void:
	var player_node: Node3D = player_scene.instantiate()
	player_node.name = str(peer_id)
	player_node.spawn = spawn_positions.get_child(spawn_position).transform
	add_child(player_node)
