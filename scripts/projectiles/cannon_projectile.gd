class_name CannonProjectile extends Projectile

signal player_hit(player_id: int)

var time: float = 0.0
var displacement: float = 0.0

# To be set by the item
var stats: ProjectileStats

var projectile_arc: ProjectileArc
var current_height: float = 0.0

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var mesh: Node3D = $Mesh

func _enter_tree() -> void:
	global_position = stats.position
	global_rotation = stats.rotation
	add_collision_exception_with(GameplayServer.get_player(stats.player_id).ship)
	
	projectile_arc = ArcFactory.create_cannon_arc(stats)

func _on_collision(collision: KinematicCollision3D):
	set_process_mode.call_deferred(ProcessMode.PROCESS_MODE_DISABLED)
	mesh.hide()
	explosion_particles.emitting = true
	
	if collision:
		if multiplayer.is_server():
			var collider = collision.get_collider()
			if collider is Ship:
				var hit_id: int = int(collider.get_parent().name)
				player_hit.emit(hit_id, stats.attack, stats.modifiers)
				GameplayServer._on_projectile_player_hit(stats.player_id, hit_id, stats.attack, stats.modifiers, stats.tags)

func _physics_process(delta: float) -> void:
	var prev_height = current_height
	var offset = delta * stats.ballistics.projectile_speed
	displacement += offset
	var next_height = projectile_arc.arc_height(displacement)
	var height_offset = next_height - prev_height
	current_height = next_height
	velocity = Vector3(0.0, 0.0, offset) * global_basis.inverse()
	velocity += Vector3(0.0, height_offset, 0.0)
	var is_underwater = global_position.y < BuoyancySolver.height(global_position)
	var collision = move_and_collide(velocity)
	if collision or is_underwater:
		_on_collision(collision)
