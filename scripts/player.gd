extends Node3D

const DEFAULT_SENSITIVITY: float = 0.25
const AIMING_SENSITIVITY: float = 0.025
const REMOTE_HP_BAR_OFFSET: Vector3 = Vector3(0.0, 1.2, 0.0)

var spawn: Transform3D # Set by Game

var orbit_sensitivity: float = DEFAULT_SENSITIVITY
var is_zooming_out: bool = false
var min_fov: float = 30.0
var max_fov: float = 90.0

var _camera_input_direction: Vector2 = Vector2.ZERO

@onready var ship: Node3D = $Ship
@onready var camera_pivot: PlayerCamera = $Ship/CameraPivot
@onready var camera: Camera3D = camera_pivot.camera
@onready var hud: Control = $HUD
@onready var controls: Control = $Controls
@onready var camera_state_machine: AnimationNodeStateMachinePlayback = camera_pivot.animation_tree.get("parameters/playback")

func _init() -> void:
	visible = false # Wait for set_spawn

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DisplayServer.has_hardware_keyboard():
		controls.hide()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	
	hud.hp_bar.max_value = ship.max_hp
	hud.hp_bar.value = ship.hp
	hud.remote_hp_bar.max_value = ship.max_hp
	hud.remote_hp_bar.value = ship.hp
	
	if not is_multiplayer_authority():
		# FIXME: Dynamically instance controls
		controls.queue_free()
		hud.local.hide()
		hud.remote.show()
		return
	
	hud.remote.hide()
	
	ship.item_selected.connect(_on_ship_item_selected)
	camera.current = true

func _exit_tree() -> void:
	if DisplayServer.has_hardware_keyboard():
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	var authority = get_multiplayer_authority()
	var player_name = multiplayer.get_unique_id()
	if authority != player_name:
		var viewport_camera = get_viewport().get_camera_3d()
		var is_behind = viewport_camera.is_position_behind(GameplayServer.get_ship(authority).global_position + REMOTE_HP_BAR_OFFSET)
		var unprojected_position: Vector2 = viewport_camera.unproject_position(GameplayServer.get_ship(authority).global_position + REMOTE_HP_BAR_OFFSET)
		hud.remote_hp_bar_container.visible = !is_behind
		hud.remote_hp_bar_container.position = unprojected_position
	
	# ship.turret.rotation.y = lerp_angle(ship.turret.rotation.y, camera_pivot.global_rotation.y - ship.global_rotation.y, 0.05)
	ship.item_instancer.rotation.x = lerp_angle(ship.item_instancer.rotation.x, camera_pivot.rotation.x - ship.global_rotation.x - TAU / 24, 0.05)

	camera_pivot.rotation.x += _camera_input_direction.y * delta
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -PI / 12.0, PI / 4.0)
	camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("shoot") or Input.is_action_pressed("aim"):
		orbit_sensitivity = AIMING_SENSITIVITY
	else:
		orbit_sensitivity = DEFAULT_SENSITIVITY
	
	if Input.is_action_pressed("aim"):
		is_zooming_out = false
		if ship.active_item is not Mortar:
			camera_state_machine.travel("cannon_scope")
		if ship.active_item is Mortar:
			camera_state_machine.travel("mortar_scope")

	if Input.is_action_just_released("aim"):
		orbit_sensitivity = DEFAULT_SENSITIVITY
		is_zooming_out = true
	
	if is_zooming_out:
		if ship.active_item is not Mortar:
			camera_state_machine.travel("default_view")
			is_zooming_out = false
		if ship.active_item is Mortar:
			camera_state_machine.travel("mortar_view")
			is_zooming_out = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction = event.screen_relative * orbit_sensitivity

func _on_ship_item_selected(item: Node):
	if item is Mortar:
		camera_state_machine.travel("mortar_view")
	if item is Cannon:
		camera_state_machine.travel("default_view")

@rpc("any_peer", "call_local", "reliable")
func set_spawn(new_spawn: Transform3D):
	if multiplayer.get_remote_sender_id() == 1:
		spawn = new_spawn
		ship.transform = spawn
		camera_pivot.rotate_y(ship.rotation.y)
		visible = true
