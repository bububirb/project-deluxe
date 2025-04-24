class_name Mortar extends Node3D

@export var projectile: PackedScene

# To be assigned by the deck
var stats: WeaponStats
var projectile_pool: Node
var player_ship: Ship

var mode: Globals.ItemMode = Globals.ItemMode.ACTIONABLE
var cooldown: float = 0.0

func execute(ship: Ship) -> void:
	if cooldown > 0.0: return
	
	var projectile_stats: ProjectileStats = ProjectileStats.new()
	
	projectile_stats.position = ship.item_instancer.global_position
	projectile_stats.rotation.y = ship.item_instancer.global_rotation.y
	
	projectile_stats.distance = ship.aiming_distance
	projectile_stats.offset = ship.aiming_height_offset
	projectile_stats.height = stats.height
	projectile_stats.speed = stats.projectile_speed
	
	_spawn_projectile.rpc(Marshalls.variant_to_base64(projectile_stats, true))
	
	cooldown = stats.cooldown
	ship.item_executed.emit(self)

@rpc("any_peer", "call_local", "reliable")
func _spawn_projectile(projectile_stats) -> void:
	projectile_stats = Marshalls.base64_to_variant(projectile_stats, true)
	var projectile_instance: Projectile = projectile.instantiate()
	projectile_instance.top_level = true
	projectile_instance.stats = projectile_stats
	projectile_pool.add_child(projectile_instance)
	projectile_instance.player_hit.connect(GameplayServer._on_projectile_player_hit)

func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown < 0.0:
		cooldown = 0.0
