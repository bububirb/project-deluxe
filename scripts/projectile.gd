extends RigidBody3D

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var mesh: Node3D = $Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node):
	sleeping = true
	mesh.hide()
	explosion_particles.emitting = true
