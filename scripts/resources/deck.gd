class_name Deck extends Node

signal item_instanced(item: Item)

@export var items: Array[Item] = []
@export var target: Node3D
@export var ship: Ship

const ITEM_SCENES_PATH: String = "res://scenes/items/"

@onready var projectile_pool: Node = $"../ProjectilePool"

func _ready() -> void:
	item_instanced.connect(ship._on_deck_item_instanced)
	for item: Item in items:
		var item_instance = _load_item_instance(item.item_name)
		item_instance.stats = item.stats
		if item_instance.mode == Globals.ItemMode.ACTIONABLE:
			item_instance.projectile_pool = projectile_pool
			item_instance.player_ship = ship
		target.add_child(item_instance)
		item_instanced.emit(item)

func _load_item_instance(item_name: String) -> Node:
	var scene: PackedScene = load(ITEM_SCENES_PATH.path_join(item_name) + ".tscn")
	return scene.instantiate()
