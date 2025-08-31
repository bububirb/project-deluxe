class_name Config extends Resource

@export var version: String = Globals.VERSION

@export var name: String = "":
	set(new_name):
		name = new_name
		MultiplayerLobby.player_info.name = new_name
@export var join_address: String = ""
@export var port: int = 7000
