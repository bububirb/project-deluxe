extends MeshInstance3D

func _process(delta: float) -> void:
	global_position.x = BuoyancySolver.player_position.x
	global_position.z = BuoyancySolver.player_position.z
	RenderingServer.global_shader_parameter_set("ocean_pos", global_position)
