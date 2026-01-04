class_name TorpedoArc extends ProjectileArc

# Arc parameters

func _init(init_trajectory: Trajectory, init_ballistics: Ballistics) -> void:
	trajectory = init_trajectory
	ballistics = init_ballistics

func arc_height(position: Vector3):
	return BuoyancySolver.height(position)

