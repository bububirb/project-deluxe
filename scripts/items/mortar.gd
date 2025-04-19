class_name Mortar extends Node3D

@export var projectile: PackedScene

# To be assigned by the deck
var stats: WeaponStats

var mode: Globals.ItemMode = Globals.ItemMode.ACTIONABLE
var cooldown: float = 0.0

func execute(ship: Ship) -> void:
	if cooldown > 0.0: return
	
	var projectile_instance: CharacterBody3D = projectile.instantiate()
	projectile_instance.top_level = true
	ship.projectile_pool.add_child(projectile_instance)
	projectile_instance.global_position = ship.item_instancer.global_position
	projectile_instance.global_rotation.y = ship.item_instancer.global_rotation.y
	projectile_instance.distance = ship.aiming_distance
	projectile_instance.offset = ship.aiming_height_offset
	projectile_instance.height = stats.height
	projectile_instance.speed = stats.projectile_speed
	cooldown = stats.cooldown
	ship.item_executed.emit(self)

func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown < 0.0:
		cooldown = 0.0
