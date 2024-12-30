extends Node3D

var orbit_sensitivity = 0.001

@onready var camera_pivot: Node3D = $Ship/CameraPivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		camera_pivot.rotate_y(-event.relative.x * orbit_sensitivity * TAU)
