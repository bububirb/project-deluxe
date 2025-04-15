extends Node3D

@onready var player: Node3D = $Player
@onready var hud: Control = $HUD

func _ready() -> void:
	player.ship.item_selected.connect(_on_ship_item_selected)

func _on_ship_item_selected(item: Node) -> void:
	var item_index = item.get_index()
	for item_sprite in hud.item_sprites.get_children():
		item_sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)
	hud.get_item(item_index).modulate = Color.WHITE
