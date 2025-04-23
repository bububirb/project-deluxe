class_name Ship extends CharacterBody3D

signal item_selected
@warning_ignore("unused_signal")
signal item_executed

signal projectile_hit

const SPEED: float = 2.0
const JUMP_VELOCITY: float = 4.5

const LINEAR_LOSS: float = 0.75
const ROTATIONAL_LOSS: float = 0.5
const MAX_SPEED_DRAG: float = 4.0
const MAX_SUBMERSION: float = 0.15

const AIMING_SENSITIVITY: float = 0.001

@export var acceleration: float = 1.0
@export var max_speed: float = 2.0
@export var motion_anisotropy: float = 5.0

@export var torque: float = 1.0
@export var max_turn_speed: float = 0.5

@export var nitro_force: float = 5.0

@export var projectile_pool: Node

var sync_position: Vector3
var sync_rotation: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var turn_speed: float = 0.0
var rotation_speed: float = 0.1

var aiming_distance: float = 30.0
var aiming_height_offset: float = 0.0
var aiming_offset: Vector2 = Vector2.ZERO

var speed_modifiers: Array[Array] = []

var active_item: Node:
	set(new_item):
		active_item = new_item
		for item in item_instancer.get_children():
			item.hide()
		active_item.show()

@onready var turret: Node3D = $Turret
@onready var item_instancer: Node3D = $Turret/ShooterTurretBase/ItemInstancer
@onready var nitro_particles = $NitroParticles
@onready var aiming_indicator: Decal = $AimingIndicator

@onready var bounds: Node3D = $Bounds
@onready var front: Node3D = $Bounds/Front
@onready var back: Node3D = $Bounds/Back
@onready var left: Node3D = $Bounds/Left
@onready var right: Node3D = $Bounds/Right

func _ready() -> void:
	await get_tree().process_frame
	select_item(0)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		position = lerp(position, sync_position, 0.5)
		rotation = lerp(rotation, sync_rotation, 0.5)
		return
	
	_update_bounds_transform()
	_snap_bounds_to_wave()
	
	_align_to_wave(delta)
	
	var input_dir := float(Input.get_action_strength("ui_up")) - float(Input.get_action_strength("ui_down"))
	var direction := (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		var new_velocity := velocity
		
		# TODO: Add a dedicated speed modifier class
		var force = acceleration
		for modifier in speed_modifiers:
			force *= modifier[0]
			modifier[1] -= delta
			if modifier[1] <= 0.0:
				speed_modifiers.erase(modifier)
		
		new_velocity.x += direction.x * force * delta
		new_velocity.z += direction.z * force * delta
		
		if velocity.length() < max_speed or new_velocity.length_squared() < velocity.length_squared() or speed_modifiers:
			velocity = new_velocity
		else:
			decelerate(delta * MAX_SPEED_DRAG)
		
		var local_velocity := transform.basis.inverse() * velocity
		local_velocity.x = move_toward(local_velocity.x, 0.0, motion_anisotropy * delta)
		velocity = transform.basis * local_velocity
	
	elif velocity.length() > max_speed:
		decelerate(delta * MAX_SPEED_DRAG)
	else:
		decelerate(delta)
	
	_clamp_submersion()
	var turn := float(Input.get_action_strength("ui_left")) - float(Input.get_action_strength("ui_right"))
	if turn:
		turn_speed = clampf(turn_speed + torque * turn * delta, -max_turn_speed, max_turn_speed)
	else:
		turn_speed = move_toward(turn_speed, 0, torque * delta * ROTATIONAL_LOSS)
	rotation.y += turn_speed * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity += transform.basis * Vector3(0.0, 0.0, nitro_force)
		nitro_particles.emitting = true
	
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):
		aiming_indicator.show()
	
	if Input.is_action_pressed("shoot"):
		aiming_distance = active_item.stats.max_range * (0.5 - aiming_offset.y) / 2.0
		var aiming_position = global_position + Vector3(0.0, 0.0, aiming_distance).rotated(Vector3.UP, turret.global_rotation.y)
		aiming_height_offset = BuoyancySolver.height(aiming_position)
		aiming_position.y += aiming_height_offset
		var size = active_item.stats.radius * 2.0
		aiming_indicator.size = Vector3(size, BuoyancySolver.WAVE_AMPLITUDE * 2.0, size)
		aiming_indicator.global_position = aiming_position
	
	if Input.is_action_just_released("shoot"):
		if active_item.mode == Globals.ItemMode.ACTIONABLE:
			aiming_offset = Vector2.ZERO
			aiming_indicator.hide()
			active_item.execute(self)
	
	if Input.is_action_just_pressed("select_item_1"):
		select_item(0)
	elif Input.is_action_just_pressed("select_item_2"):
		select_item(1)
	elif Input.is_action_just_pressed("select_item_3"):
		select_item(2)
	elif Input.is_action_just_pressed("select_item_4"):
		select_item(3)
	elif Input.is_action_just_pressed("select_item_5"):
		select_item(4)
	
	sync_position = position
	sync_rotation = rotation

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("shoot"):
			aiming_offset += event.relative * AIMING_SENSITIVITY
			aiming_offset.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))

func decelerate(delta):
	velocity.x = move_toward(velocity.x, 0, acceleration * delta * LINEAR_LOSS)
	velocity.z = move_toward(velocity.z, 0, acceleration * delta * LINEAR_LOSS)

func _update_bounds_transform():
	bounds.global_position = global_position
	bounds.global_rotation.y = rotation.y

func _snap_bounds_to_wave():
	for node in bounds.get_children():
		node.global_position.y = BuoyancySolver.height(node.global_position)

func _align_to_wave(delta: float) -> void:
	var relative_height: float = global_position.y - BuoyancySolver.height(global_position)
	
	rotation.x = lerp_angle(rotation.x, front.global_position.y - back.global_position.y, clamp(remap(relative_height, -0.2, 0.2, 0.2, 0.0), 0.01, 0.2))
	rotation.z = lerp_angle(rotation.z, right.global_position.y - left.global_position.y, clamp(remap(relative_height, -0.2, 0.2, 0.2, 0.0), 0.01, 0.2))
	
	velocity.y += BuoyancySolver.get_buoyancy_force(global_position, delta)
	velocity.y *= BuoyancySolver.DAMPING

func _clamp_submersion() -> void:
	global_position.y = max(global_position.y, BuoyancySolver.height(global_position) - MAX_SUBMERSION)

func select_item(index: int) -> void:
	if index >= item_instancer.get_child_count(): return
	
	var selected_item: Node = item_instancer.get_child(index)
	if selected_item.mode == Globals.ItemMode.USABLE:
		selected_item.execute(self)
	elif selected_item.mode == Globals.ItemMode.ACTIONABLE:
		active_item = selected_item
		item_selected.emit(active_item)

func _on_projectile_player_hit(player_id: int):
	_hit_test.rpc(player_id)

@rpc("authority","call_local","reliable")
func _hit_test(hit_id: int):
	if multiplayer.get_unique_id() == hit_id:
		print(str(multiplayer.get_unique_id()),": I got hit!")
		projectile_hit.emit()
	else:
		print(str(multiplayer.get_unique_id()),": ",str(hit_id)," got hit!")
