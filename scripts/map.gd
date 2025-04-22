extends Node3D

@export var player_scene: PackedScene

@onready var player: Node3D# = $Player
@onready var spawn_positions: Node3D = $SpawnPositions
@onready var hud: Control = $HUD

func _ready() -> void:
	MultiplayerLobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	
	#player.ship.item_selected.connect(_on_ship_item_selected)
	#player.ship.item_executed.connect(_on_ship_item_executed)
	
	#for item: Node in player.ship.item_instancer.get_children():
	#	var item_index = item.get_index()
	#	hud.get_item_cooldown(item_index).max_value = item.stats.cooldown + 1.0

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	BuoyancySolver.reset_wave_time.rpc()
	for i in MultiplayerLobby.players.keys().size():
		var peer_id: int = MultiplayerLobby.players.keys()[i]
		add_player(peer_id, i)
	pass

func add_player(peer_id: int, spawn_position: int) -> void:
	var player_node: Node3D = player_scene.instantiate()
	player_node.name = str(peer_id)
	add_child(player_node)
	player_node.global_transform = spawn_positions.get_child(spawn_position).global_transform

func _on_ship_item_selected(item: Node) -> void:
	var item_index = item.get_index()
	for item_sprite in hud.item_sprites.get_children():
		item_sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)
	hud.get_item(item_index).modulate = Color.WHITE

func _on_ship_item_executed(item: Node) -> void:
	var item_index = item.get_index()
	hud.get_item_cooldown(item_index).value = 0.0
