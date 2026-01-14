extends Node3D

@export var offset: float = 0.0
@export var speed: float = 1.0

func _process(delta: float) -> void:
	rotate_object_local(Vector3.UP, delta * speed)
