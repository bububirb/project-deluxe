class_name MortarProjectile extends Projectile

signal player_hit(player_id: int)

@export var explosion_scene: PackedScene

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
	
	projectile_arc = ArcFactory.create_mortar_arc(stats)

func _on_collision(_collision: KinematicCollision3D):
	set_process_mode.call_deferred(ProcessMode.PROCESS_MODE_DISABLED)
	mesh.hide()
	explosion_particles.emitting = true
	if explosion_scene:
		var explosion_node = explosion_scene.instantiate()
		explosion_node.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(explosion_node)
	
	if multiplayer.is_server():
		GameplayServer._on_aoe_projectile_hit(stats.player_id, global_position, stats.radius, stats.attack, stats.modifiers, stats.tags)

func _physics_process(delta: float) -> void:
	var prev_height = current_height
	var offset = delta * stats.distance / stats.ballistics.travel_time
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
