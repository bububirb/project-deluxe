extends Node3D # Or Node2D.

signal server_loaded

func _ready():
	# Preconfigure game.
	if multiplayer.is_server():
		_on_server_loaded.rpc()
	else:
		get_tree().paused = true
		await server_loaded
		get_tree().paused = false
	
	MultiplayerLobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	pass

@rpc("authority", "call_remote", "reliable")
func _on_server_loaded() -> void:
	server_loaded.emit()
