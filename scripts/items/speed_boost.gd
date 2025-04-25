class_name SpeedBoost extends Node3D

# To be assigned by the deck
var stats: SpeedStats

var mode: Globals.ItemMode = Globals.ItemMode.USABLE
var cooldown: float = 0.0

func execute(ship: Ship) -> void:
	if cooldown > 0.0: return
	
	GameplayServer.boost.rpc_id(1, multiplayer.get_unique_id(), get_index())
	ship.item_executed.emit(self)

func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown < 0.0:
		cooldown = 0.0
