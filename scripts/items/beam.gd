class_name Beam extends Node3D

@export var projectile: PackedScene

# To be assigned by the deck
var stats: WeaponStats
var projectile_pool: Node
var player_ship: Ship

var item_class: Globals.ItemClass = Globals.ItemClass.BEAM
var mode: Globals.ItemMode = Globals.ItemMode.ACTIONABLE
var cooldown: float = 0.0

func execute() -> void:
	if cooldown > 0.0: return
	
	GameplayServer.shoot.rpc_id(1, multiplayer.get_unique_id(), get_index())

func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown < 0.0:
		cooldown = 0.0
