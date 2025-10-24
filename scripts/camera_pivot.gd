class_name PlayerCamera extends Node3D

@export var weight: float = 0.75
@export var animation_tree: AnimationTree
@onready var target: Ship = get_parent()

func _process(_delta: float) -> void:
	if target:
		global_position = lerp(global_position, target.global_position, weight)
