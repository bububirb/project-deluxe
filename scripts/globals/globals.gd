extends Node

const VERSION: String = "0.1.0"

const PLAYER_SCENES_DIRECTORY: String = "res://scenes/players"
const MAP_SCENES_DIRECTORY: String = "res://scenes/maps"

const GAME_SCENE_PATH: String = "res://scenes/maps/game.tscn"
const LOADING_SCENE_PATH: String = "res://scenes/ui/loading_screen.tscn"

const MAIN_SCENE: PackedScene = preload("res://scenes/drafts/main.tscn")
const LOBBY_SCENE: PackedScene = preload("res://scenes/ui/lobby.tscn")
const GAME_ROOM_SCENE: PackedScene = preload("res://scenes/ui/game_room.tscn")
const LOADING_SCENE: PackedScene = preload(LOADING_SCENE_PATH)
const GAME_SCENE: PackedScene = preload(GAME_SCENE_PATH)
const RESULTS_SCENE: PackedScene = preload("res://scenes/ui/results.tscn")

enum ItemMode {ACTIONABLE, USABLE, PASSIVE}
enum ItemClass {CANNON, MORTAR, BEAM, TORPEDO, SPEED_BOOST}
enum ModifierType {BUFF, DEBUFF}

func _init() -> void:
	ProjectSettings.set_setting("display/window/stretch/scale", DisplayServer.screen_get_scale())

