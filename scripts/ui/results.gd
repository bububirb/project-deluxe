extends Control

const LOBBY_SCENE_PATH: String = "res://scenes/ui/lobby.tscn"
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
	get_tree().change_scene_to_file(LOBBY_SCENE_PATH)
