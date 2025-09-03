class_name TorpedoArc extends ProjectileArc

# Arc parameters

func _init(projectile_stats: ProjectileStats) -> void:
	stats = projectile_stats

func arc_height(position: Vector3):
	return BuoyancySolver.height(position)

