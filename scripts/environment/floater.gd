extends RigidBody3D

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	linear_velocity.y += BuoyancySolver.get_buoyancy_force(global_position, 1.0 / Engine.physics_ticks_per_second)
	linear_velocity.y *= BuoyancySolver.DAMPING
	
