extends Node3D

const DEFAULT_SENSITIVITY: float = 0.001
const AIMING_SENSITIVITY: float = 0.0001

var spawn: Transform3D # Set by Game

var orbit_sensitivity: float = DEFAULT_SENSITIVITY
var is_zooming_out: bool = false
var min_fov: float = 30.0
var max_fov: float = 90.0

@onready var ship: Node3D = $Ship
@onready var camera_pivot: Node3D = $Ship/CameraPivot
@onready var camera_pivot_x: Node3D = $Ship/CameraPivot/CameraPivotX
@onready var camera: Camera3D = $Ship/CameraPivot/CameraPivotX/Camera
@onready var hud: Control = $HUD
@onready var controls: Control = $Controls

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ship.transform = spawn
	if DisplayServer.has_hardware_keyboard():
		controls.hide()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	
	if not is_multiplayer_authority():
		# FIXME: Dynamically instance controls
		controls.queue_free()
		return
	hud.show()
	hud.hp_bar.max_value = ship.max_hp
	hud.hp_bar.value = ship.hp
	
	ship.item_selected.connect(_on_ship_item_selected)
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# ship.turret.rotation.y = lerp_angle(ship.turret.rotation.y, camera_pivot.global_rotation.y - ship.global_rotation.y, 0.05)
	ship.item_instancer.rotation.x = lerp_angle(ship.item_instancer.rotation.x, camera_pivot_x.rotation.x - ship.global_rotation.x - TAU / 24, 0.05)
	
	if Input.is_action_pressed("shoot") or Input.is_action_pressed("aim"):
		orbit_sensitivity = 0.0
	else:
		orbit_sensitivity = DEFAULT_SENSITIVITY
	
	if Input.is_action_pressed("aim"):
		is_zooming_out = false
		if ship.active_item is not Mortar:
			camera.fov = lerp(camera.fov, min_fov, 0.2)
		if ship.active_item is Mortar:
			var tween = create_tween().tween_property(camera, "position:z", -3.5, 0.4)
			await tween.finished

	if Input.is_action_just_released("aim"):
		orbit_sensitivity = DEFAULT_SENSITIVITY
		is_zooming_out = true
	
	if is_zooming_out:
		if ship.active_item is not Mortar:
			camera.fov = lerp(camera.fov, max_fov, 0.2)
			if camera.fov >= max_fov:
				camera.fov = max_fov
				is_zooming_out = false
		if ship.active_item is Mortar:
			var tween = create_tween().tween_property(camera, "position:z", -2.2, 0.4)
			await tween.finished
			is_zooming_out = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * orbit_sensitivity * TAU)
		camera_pivot_x.rotate_x(event.relative.y * orbit_sensitivity * TAU)
	elif event is InputEventScreenDrag:
		camera_pivot.rotate_y(-event.relative.x * orbit_sensitivity * TAU)
		camera_pivot_x.rotate_x(event.relative.y * orbit_sensitivity * TAU)
	camera_pivot_x.rotation.x = clampf(camera_pivot_x.rotation.x, - TAU / 24, TAU / 8)
	camera_pivot_x.rotation.y = 0.0
	camera_pivot_x.rotation.z = 0.0

func _on_ship_item_selected(item: Node):
	if item is Mortar:
		var _tween = create_tween().tween_property(camera, "position:z", -2.2, 0.15)
	if item is Cannon:
		var _tween = create_tween().tween_property(camera, "position:z", -1.6, 0.15)
