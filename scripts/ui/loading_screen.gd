extends Control

@export var loading_progress_bar: ProgressBar

var progress: Array = []
var loaded: bool = false

var polling = false
@onready var id = multiplayer.get_unique_id()

func _ready() -> void:
	MultiplayerLobby.server_status_return.connect(_on_server_status_return)
	ResourceLoader.load_threaded_request(Globals.get_map_path())

func _process(_delta: float) -> void:
	var err: ResourceLoader.ThreadLoadStatus
	if not loaded:
		err = ResourceLoader.load_threaded_get_status(Globals.get_map_path(), progress)
		if err == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			loading_progress_bar.value = progress[0]
		if err == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			MultiplayerLobby.status = MultiplayerLobby.ServerStatus.LOADED
			loaded = true
	elif id == 1:
		_load_game()
	elif not polling:
		polling = true
		MultiplayerLobby.poll_server_status.rpc_id(1)

func _load_game() -> void:
	Globals.map = ResourceLoader.load_threaded_get(Globals.get_map_path())
	get_tree().change_scene_to_packed(Globals.GAME_SCENE)

func _on_server_status_return(status: MultiplayerLobby.ServerStatus) -> void:
	polling = false
	if status == MultiplayerLobby.ServerStatus.LOADED:
		_load_game()
