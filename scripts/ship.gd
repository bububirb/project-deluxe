extends CharacterBody3D

const SPEED: float = 2.0
const JUMP_VELOCITY: float = 4.5

const LINEAR_LOSS: float = 0.75
const ROTATIONAL_LOSS: float = 0.5
const MAX_SPEED_DRAG: float = 4.0
const MAX_SUBMERSION: float = 0.3

@export var acceleration: float = 1.0
@export var max_speed: float = 2.0
@export var motion_anisotropy: float = 5.0

@export var torque: float = 1.0
@export var max_turn_speed: float = 0.5

@export var nitro_force: float = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var turn_speed: float = 0.0
var rotation_speed: float = 0.1

@onready var nitro_particles = $NitroParticles

@onready var bounds: Node3D = $Bounds
@onready var front: Node3D = $Bounds/Front
@onready var back: Node3D = $Bounds/Back
@onready var left: Node3D = $Bounds/Left
@onready var right: Node3D = $Bounds/Right

func _physics_process(delta: float) -> void:
	update_bounds_transform()
	for node in bounds.get_children():
		node.global_position.y = BuoyancySolver.height(node.global_position)
	
	var relative_height: float = global_position.y - BuoyancySolver.height(global_position)
	
	rotation.x = lerp_angle(rotation.x, front.global_position.y - back.global_position.y, clamp(remap(relative_height, -0.2, 0.2, 0.2, 0.0), 0.01, 0.2))
	rotation.z = lerp_angle(rotation.z, right.global_position.y - left.global_position.y, clamp(remap(relative_height, -0.2, 0.2, 0.2, 0.0), 0.01, 0.2))
	
	velocity.y += BuoyancySolver.get_buoyancy_force(global_position, delta)
	velocity.y *= BuoyancySolver.DAMPING
	
	var input_dir := float(Input.get_action_strength("ui_down")) - float(Input.get_action_strength("ui_up"))
	var direction := (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		var new_velocity := velocity
		new_velocity.x += direction.x * acceleration * delta
		new_velocity.z += direction.z * acceleration * delta
		#velocity = velocity.limit_length(max_speed)
		if velocity.length() > max_speed:
			if new_velocity.length() < velocity.length():
				velocity = new_velocity
			else:
				decelerate(delta * MAX_SPEED_DRAG)
		else:
			velocity = new_velocity
		var local_velocity := transform.basis.inverse() * velocity
		local_velocity.x = move_toward(local_velocity.x, 0.0, motion_anisotropy * delta)
		velocity = transform.basis * local_velocity
	elif velocity.length() > max_speed:
		decelerate(delta * MAX_SPEED_DRAG)
	else:
		decelerate(delta)
	
	global_position.y = max(global_position.y, BuoyancySolver.height(global_position) - MAX_SUBMERSION)
	
	var turn := float(Input.get_action_strength("ui_left")) - float(Input.get_action_strength("ui_right"))
	if turn:
		turn_speed = clampf(turn_speed + torque * turn * delta, -max_turn_speed, max_turn_speed)
	else:
		turn_speed = move_toward(turn_speed, 0, torque * delta * ROTATIONAL_LOSS)
	rotation.y += turn_speed * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity += transform.basis * Vector3(0.0, 0.0, -nitro_force)
		nitro_particles.emitting = true
	
	
	#var slope := BuoyancySolver.get_slope(global_position,  0.2)
	#var normal := Vector3(-slope.x, 1, -slope.y).normalized()
	#var current_up := transform.basis.y
	#var target_up := normal
	#var rotation_axis := current_up.cross(target_up).normalized()
	#var rotation_angle := acos(current_up.dot(target_up))
	#var interpolated_rotation := transform.basis.get_rotation_quaternion().slerp(Quaternion(rotation_axis, rotation_angle), rotation_speed)
	#rotation.x = interpolated_rotation.get_euler().x
	#rotation.z = interpolated_rotation.get_euler().z
	
	#global_rotation = BuoyancySolver.get_slope(global_position, 0.1)
	
	move_and_slide()

func decelerate(delta):
	velocity.x = move_toward(velocity.x, 0, acceleration * delta * LINEAR_LOSS)
	velocity.z = move_toward(velocity.z, 0, acceleration * delta * LINEAR_LOSS)


func update_bounds_transform():
	bounds.global_position = global_position
	bounds.global_rotation.y = rotation.y
