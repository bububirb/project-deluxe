class_name Cannon extends Node3D

@export var projectile: PackedScene

var stats: WeaponStats # To be assigned by the deck

func execute(ship: Ship) -> void:
	var projectile_instance: RigidBody3D = projectile.instantiate()
	projectile_instance.top_level = true
	projectile_instance.position = ship.item_instancer.global_position
	projectile_instance.linear_velocity = ship.item_instancer.global_transform.basis * Vector3(0.0, 0.0, 30.0)
	ship.projectile_pool.add_child(projectile_instance)
