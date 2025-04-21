class_name Deck extends Node

@export var items: Array[Item] = []
@export var target: Node3D

const ITEM_SCENES_PATH: String = "res://scenes/items/"

@onready var projectile_pool: Node = $"../ProjectilePool"

func _ready() -> void:
	for item: Item in items:
		var item_instance = _load_item_instance(item.item_name)
		item_instance.stats = item.stats
		if item_instance.mode == Globals.ItemMode.ACTIONABLE:
			item_instance.projectile_pool = projectile_pool
		target.add_child(item_instance)

func _load_item_instance(item_name: String) -> Node:
	var scene: PackedScene = load(ITEM_SCENES_PATH.path_join(item_name) + ".tscn")
	return scene.instantiate()
