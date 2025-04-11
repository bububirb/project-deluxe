extends RigidBody3D

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var mesh: Node3D = $Mesh

func _on_body_entered(_body: Node):
	sleeping = true
	mesh.hide()
	explosion_particles.emitting = true
