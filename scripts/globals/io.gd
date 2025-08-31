extends Node

@export var config: Config

const CONFIG_PATH: String = "user://config/"
const CONFIG_FILE: String = "config.tres"

func _ready() -> void:
	load_config()

func _exit_tree() -> void:
	save_config()

func load_config() -> void:
	var dir = DirAccess.open(CONFIG_PATH)
	if dir:
		if dir.file_exists(CONFIG_FILE):
			config = ResourceLoader.load(CONFIG_PATH + CONFIG_FILE)
			return
	config = Config.new()

func save_config() -> void:
	var dir = DirAccess.open(CONFIG_PATH)
	if not dir:
		DirAccess.make_dir_recursive_absolute(CONFIG_PATH)
		dir = DirAccess.open(CONFIG_PATH)
	ResourceSaver.save(config, CONFIG_PATH + CONFIG_FILE)
