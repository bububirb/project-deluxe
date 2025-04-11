extends Node3D

var orbit_sensitivity = 0.001

@onready var ship: Node3D = $Ship
@onready var camera_pivot: Node3D = $Ship/CameraPivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	ship.turret.rotation.y = lerp_angle(ship.turret.rotation.y, camera_pivot.global_rotation.y - ship.global_rotation.y, 0.05)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * orbit_sensitivity * TAU)
	elif event is InputEventScreenDrag:
		camera_pivot.rotate_y(-event.relative.x * orbit_sensitivity * TAU)
