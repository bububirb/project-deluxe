extends Node3D

@export var weight: float = 0.75
@onready var target: Node3D = get_parent()

func _process(_delta: float) -> void:
	if target:
		global_position = lerp(global_position, target.global_position, weight)
