class_name Cannon extends Node3D

@export var projectile: PackedScene

# To be assigned by the deck
var mode: Globals.ItemMode
var stats: WeaponStats

var cooldown: float = 0.0

func execute(ship: Ship) -> void:
	if cooldown > 0.0: return
	
	var projectile_instance: RigidBody3D = projectile.instantiate()
	projectile_instance.top_level = true
	projectile_instance.position = ship.item_instancer.global_position
	projectile_instance.linear_velocity = ship.item_instancer.global_transform.basis * Vector3(0.0, 0.0, stats.range)
	ship.projectile_pool.add_child(projectile_instance)
	cooldown = stats.cooldown
	ship.item_executed.emit(self)

func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown < 0.0:
		cooldown = 0.0
