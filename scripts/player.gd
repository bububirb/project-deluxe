extends Node3D

var orbit_sensitivity = 0.001
var is_zooming_out = false
var min_fov: float = 30.0
var max_fov: float = 90.0

@onready var ship: Node3D = $Ship
@onready var camera_pivot: Node3D = $Ship/CameraPivot
@onready var camera: Camera3D = $Ship/CameraPivot/Camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	ship.turret.rotation.y = lerp_angle(ship.turret.rotation.y, camera_pivot.global_rotation.y - ship.global_rotation.y, 0.05)
	
	if Input.is_action_pressed("aim"):
		is_zooming_out = false
		camera.fov = lerp(camera.fov, min_fov, 0.2)

	if Input.is_action_just_released("aim"):
		is_zooming_out = true
	
	if is_zooming_out:
		camera.fov = lerp(camera.fov, max_fov, 0.2)
		if camera.fov >= max_fov:
			camera.fov = max_fov
			is_zooming_out = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * orbit_sensitivity * TAU)
	elif event is InputEventScreenDrag:
		camera_pivot.rotate_y(-event.relative.x * orbit_sensitivity * TAU)
