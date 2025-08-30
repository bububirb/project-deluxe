extends Control

const GAME_ROOM_SCENE: String = "res://scenes/ui/game_room.tscn"
const PLAYER_RESULTS_CONTAINER = preload("res://scenes/ui/player_results_container.tscn")

@export var players_container: VBoxContainer
@export var exit_button: Button

func _ready() -> void:
	for player_id in GameplayServer.get_player_ids():
		var player_results: Node = PLAYER_RESULTS_CONTAINER.instantiate()
		player_results.set_player_name(MultiplayerLobby.players[player_id].name)
		#player_results.set_damage(GameplayServer.get_ship(player_id).damage_dealt)
		player_results.set_damage(GameplayServer.damage_dealt[player_id])
		players_container.add_child(player_results)

func _on_exit_button_pressed() -> void:
	back_to_game_room.rpc()

@rpc("authority", "call_local", "reliable")
func back_to_game_room() -> void:
	get_tree().change_scene_to_file(GAME_ROOM_SCENE)
