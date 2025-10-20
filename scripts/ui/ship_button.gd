@tool
class_name ShipButton extends Button

const SHIP_SPRITES_PATH: String = "res://assets/sprites/ships/"

@export var ship_name: String:
	set(new_ship_name):
		ship_name = new_ship_name
		for child in get_children():
			child.queue_free()
		var dir = DirAccess.open(SHIP_SPRITES_PATH)
		if dir.file_exists(ship_name + ".png"):
			var sprite: Texture2D = load(SHIP_SPRITES_PATH + ship_name + ".png")
			if sprite:
				icon = sprite

func _ready() -> void:
	pressed.connect(MultiplayerLobby._on_player_ship_set.bind(ship_name))
