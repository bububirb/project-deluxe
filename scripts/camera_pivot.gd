class_name PlayerCamera extends Node3D

@export var speed: float = 50.0
@export var height: float = 0.75
@export var animation_tree: AnimationTree
@export var camera: Camera3D
@onready var target: Ship = get_parent()

var _target_position: Vector3

func _ready() -> void:
	_update_target_position()
	global_position = _target_position

func _physics_process(delta: float) -> void:
	_update_target_position()
	if target:
		global_position = global_position.move_toward(_target_position, speed * delta)

func _update_target_position() -> void:
	_target_position = target.global_position
	_target_position.y += height
