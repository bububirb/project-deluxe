extends Node3D

@onready var player: Node3D = $Player
@onready var hud: Control = $HUD

func _ready() -> void:
	player.ship.item_selected.connect(_on_ship_item_selected)
	player.ship.item_executed.connect(_on_ship_item_executed)
	
	for item: Node in player.ship.item_instancer.get_children():
		var item_index = item.get_index()
		hud.get_item_cooldown(item_index).max_value = item.stats.cooldown + 1.0

func _on_ship_item_selected(item: Node) -> void:
	var item_index = item.get_index()
	for item_sprite in hud.item_sprites.get_children():
		item_sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)
	hud.get_item(item_index).modulate = Color.WHITE

func _on_ship_item_executed(item: Node) -> void:
	var item_index = item.get_index()
	hud.get_item_cooldown(item_index).value = 0.0
