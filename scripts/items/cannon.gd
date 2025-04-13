extends Node3D

@export var projectile: PackedScene

var stats: WeaponStats # To be assigned by the deck

func shoot(from: Node3D, projectile_pool: Node) -> void:
	var projectile_instance: RigidBody3D = projectile.instantiate()
	projectile_instance.top_level = true
	projectile_instance.position = from.global_position
	projectile_instance.linear_velocity = from.global_transform.basis * Vector3(0.0, 0.0, 30.0)
	projectile_pool.add_child(projectile_instance)
