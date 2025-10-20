@tool
class_name ShipSelection extends HBoxContainer

const SHIP_SPRITES_PATH = "res://assets/sprites/ships/"

@export var button_scene: PackedScene
@export var ships: Array[String]:
	set(new_ships):
		ships = new_ships
		for child in get_children():
			child.queue_free()
		if button_scene:
			for ship: String in ships:
				var button: ShipButton = button_scene.instantiate()
				button.ship_name = ship
				add_child(button)
