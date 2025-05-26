class_name Ship extends CharacterBody3D

signal item_selected
signal item_instanced(item: Item)

const SPEED: float = 2.0
const JUMP_VELOCITY: float = 4.5

const ROTATIONAL_LOSS: float = 0.5
const MAX_SUBMERSION: float = 0.15
const MAX_SPEED_DRAG: float = 4.0

const AIMING_SENSITIVITY: float = 0.001
const AIMING_RANGE: float = 2.0

@export var linear_loss: float = 0.75
@export var acceleration: float = 1.0
@export var max_speed: float = 2.0
@export var motion_anisotropy: float = 5.0

@export var torque: float = 1.0
@export var max_turn_speed: float = 0.5

@export var nitro_force: float = 5.0

@export var projectile_pool: Node

@export_group("Stats")
@export var max_hp: int = 10000
@export var attack: int = 1000
@export var defense: int = 500

var hp: int = max_hp
var alive: bool = true

var sync_position: Vector3
var sync_rotation: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var turn_speed: float = 0.0
var rotation_speed: float = 0.1

var input_dir: float = 0.0
var turn: float = 0.0

var aiming_distance: float = 30.0
var aiming_height_offset: float = 0.0
var aiming_offset: Vector2 = Vector2.ZERO
var aiming_position: Vector3
var ships: Array[Ship]
var closest_target: Ship

var colliding_shipwrecks: Array[Ship]
var shipwreck_timer: float = 0.0

var modifiers: Array[Modifier]

var active_item: Node:
	set(new_item):
		active_item = new_item
		set_visible_item(active_item)
		GameplayServer.set_visible_item.rpc(active_item.get_index())

@onready var turret: Node3D = $Turret
@onready var item_instancer: Node3D = $Turret/TurretBase/ItemInstancer
@onready var nitro_particles = $NitroParticles
@onready var aiming_indicator: Decal = $AimingIndicator
@onready var crosshair: Sprite3D = $Crosshair
@onready var deck: Deck = $Deck
@onready var burn: AnimatedSprite3D = $Burn
@onready var fire: Node3D = $Particles/Fire
@onready var explosion: Node3D = $Particles/Explosion

@onready var bounds: Node3D = $Bounds
@onready var front: Node3D = $Bounds/Front
@onready var back: Node3D = $Bounds/Back
@onready var left: Node3D = $Bounds/Left
@onready var right: Node3D = $Bounds/Right

func _ready() -> void:
	await get_tree().process_frame
	if not is_multiplayer_authority(): return
	select_item(0)
	crosshair.show()
	ships = GameplayServer.get_ships()
	ships.erase(self)

func _physics_process(delta: float) -> void:
	_modifier_tick(delta)
	if multiplayer.is_server(): _shipwreck_tick(delta)
	
	if not is_multiplayer_authority():
		position = lerp(position, sync_position, 0.5)
		rotation = lerp(rotation, sync_rotation, 0.5)
		return
	
	_update_bounds_transform()
	_snap_bounds_to_wave()
	_align_to_wave(delta)
	
	var speed_cap = max_speed
	var direction := (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		var new_velocity := velocity
		
		var force = acceleration
		for modifier: SpeedModifier in get_speed_modifiers():
			force *= modifier.speed_multiplier
			speed_cap *= modifier.speed_multiplier
		
		new_velocity.x += direction.x * force * delta
		new_velocity.z += direction.z * force * delta
		
		if velocity.length() < speed_cap or new_velocity.length_squared() < velocity.length_squared():
			velocity = new_velocity
		else:
			decelerate(delta * MAX_SPEED_DRAG)
	
	elif velocity.length() > speed_cap:
		decelerate(delta * MAX_SPEED_DRAG)
	else:
		decelerate(delta)
	
	_clamp_submersion()
	var local_velocity := transform.basis.inverse() * velocity
	var local_velocity_xz = Vector3(local_velocity.x, 0.0, local_velocity.z) # Discard vertical movement
	# Tilt velocity based on anisotropy
	local_velocity_xz = local_velocity_xz.move_toward(local_velocity_xz.project(Vector3.MODEL_FRONT), motion_anisotropy * delta)
	local_velocity_xz.y = local_velocity.y # Reintroduce vertical movement
	local_velocity = local_velocity_xz
	# local_velocity.x = move_toward(local_velocity.x, 0.0, motion_anisotropy * delta)
	velocity = transform.basis * local_velocity
	
	if turn:
		turn_speed = clampf(turn_speed + torque * turn * delta, -max_turn_speed, max_turn_speed)
	else:
		turn_speed = move_toward(turn_speed, 0, torque * delta * ROTATIONAL_LOSS)
	rotation.y += turn_speed * delta
	
	move_and_slide()
	sync_position = position
	sync_rotation = rotation
	
	for ship: Ship in ships:
		if not closest_target:
			closest_target = ship
		elif position.distance_squared_to(ship.position) < position.distance_squared_to(closest_target.position):
			closest_target = ship
	if closest_target:
		var current_position = global_position
		current_position.y = 0.0
		var target_position = closest_target.global_position
		var offset_vector = Vector3(-aiming_offset.x * AIMING_RANGE, -aiming_offset.y * AIMING_RANGE, -aiming_offset.y * AIMING_RANGE).rotated(Vector3.UP, turret.global_rotation.y)
		target_position.y = 0.0
		aiming_distance = current_position.distance_to(target_position)
		aiming_height_offset = closest_target.turret.global_position.y - item_instancer.global_position.y - aiming_offset.y
		turret.look_at(closest_target.position, Vector3(0.0, 1.0, 0.0), true)
		turret.rotation.x = 0.0
		turret.rotation.z = 0.0
		aiming_position = aiming_position.move_toward(closest_target.turret.global_position + offset_vector, delta * 25.0)
		crosshair.global_position = aiming_position

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if alive:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("shoot"):
				aiming_offset += event.relative * AIMING_SENSITIVITY
				aiming_offset.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		
		if DisplayServer.has_hardware_keyboard():
			input_dir = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
			turn = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
		
		if Input.is_action_just_pressed("ui_accept"):
			velocity += transform.basis * Vector3(0.0, 0.0, nitro_force)
			nitro_particles.emitting = true
		
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
		
		if active_item:
			if Input.is_action_just_pressed("shoot"):
				aiming_indicator.show()
			
			if Input.is_action_pressed("shoot"):
				var size = active_item.stats.radius * 2.0
				aiming_indicator.size = Vector3(size, BuoyancySolver.WAVE_AMPLITUDE * 2.0, size)
				aiming_indicator.global_position = aiming_position
			
			if Input.is_action_just_released("shoot"):
				if active_item.mode == Globals.ItemMode.ACTIONABLE:
					aiming_indicator.hide()
					active_item.execute()
					aiming_offset = Vector2.ZERO

func decelerate(delta):
	velocity.x = move_toward(velocity.x, 0, acceleration * delta * linear_loss)
	velocity.z = move_toward(velocity.z, 0, acceleration * delta * linear_loss)

func _update_bounds_transform():
	bounds.global_position = global_position
	bounds.global_rotation.y = rotation.y

func _snap_bounds_to_wave():
	pass
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

func set_visible_item(item: Node) -> void:
	for item_instance in item_instancer.get_children():
		item_instance.hide()
	item.show()

func select_item(index: int) -> void:
	if index >= item_instancer.get_child_count(): return
	
	var selected_item: Node = get_item(index)
	if selected_item.mode == Globals.ItemMode.USABLE:
		selected_item.execute()
	elif selected_item.mode == Globals.ItemMode.ACTIONABLE:
		active_item = selected_item
		item_selected.emit(active_item)

func get_item(index: int) -> Node3D:
	return item_instancer.get_child(index)

func _on_deck_item_instanced(item: Item):
	item_instanced.emit(item)

func kill() -> void:
	alive = false
	fire.start()
	explosion.start()
	input_dir = 0.0
	turn = 0.0

func get_speed_modifiers() -> Array[SpeedModifier]:
	var speed_modifiers: Array[SpeedModifier]
	for modifier: Modifier in modifiers:
		if modifier is SpeedModifier:
			speed_modifiers.append(modifier)
	return speed_modifiers

func get_additive_defense_modifiers() -> Array[AdditiveDefenseModifier]:
	var additive_defense_modifiers: Array[AdditiveDefenseModifier]
	for modifier: Modifier in modifiers:
		if modifier is AdditiveDefenseModifier:
			additive_defense_modifiers.append(modifier)
	return additive_defense_modifiers

func get_burn_modifiers() -> Array[BurnModifier]:
	var burn_modifiers: Array[BurnModifier]
	for modifier: Modifier in modifiers:
		if modifier is BurnModifier:
			burn_modifiers.append(modifier)
	return burn_modifiers

func get_defense() -> int:
	var defense_multiplier: float = 1.0
	for additive_defense_modifier: AdditiveDefenseModifier in get_additive_defense_modifiers():
		defense_multiplier += additive_defense_modifier.amount
	return roundi(float(defense) * defense_multiplier)

func add_modifier(modifier: Modifier):
	modifiers.append(modifier)
	if modifier is BurnModifier:
		burn.show()

func _modifier_tick(delta: float) -> void:
	for modifier in modifiers:
		modifier.duration -= delta
		if modifier is BurnModifier:
			modifier.burn_counter += delta
			if modifier.burn_counter >= modifier.tick_duration:
				_fire_tick(modifier)
		if modifier.duration <= 0.0:
			modifiers.erase(modifier)
			if modifier is BurnModifier:
				if not get_burn_modifiers():
					burn.hide()

func _fire_tick(burn_modifier: BurnModifier) -> void:
	burn_modifier.burn_counter -= burn_modifier.tick_duration
	var burn_damage = Math.calculate_damage(burn_modifier.damage, self)
	GameplayServer._deal_fire_damage(get_multiplayer_authority(), burn_damage)

func _shipwreck_tick(delta: float) -> void:
	if colliding_shipwrecks.size() > 0:
		shipwreck_timer += delta
	else:
		shipwreck_timer = 0.0
	if shipwreck_timer >= GameplayServer.SHIPWRECK_TICK_DURATION:
		shipwreck_timer = 0.0
		GameplayServer._on_shipwreck_tick(get_multiplayer_authority(), GameplayServer.SHIPWRECK_DAMAGE)

func _on_collision_detector_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server(): return
	if body is Ship:
		if not body.alive and not colliding_shipwrecks.has(body):
			colliding_shipwrecks.append(body)

func _on_collision_detector_body_exited(body: Node3D) -> void:
	if body is Ship:
		if colliding_shipwrecks.has(body):
			colliding_shipwrecks.erase(body)

func _on_movement_joystick_analogic_change(move: Vector2) -> void:
	if alive and DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN):
		input_dir = -move.y
		if input_dir > 0.0:
			turn = -move.x
		else:
			turn = move.x

func _on_movement_joystick_analogic_released() -> void:
	input_dir = 0.0
	turn = 0.0

func _on_aiming_joystick_analogic_just_pressed() -> void:
	Input.action_press("shoot")

func _on_aiming_joystick_analogic_change(move: Vector2) -> void:
	aiming_offset = move

func _on_aiming_joystick_analogic_released() -> void:
	Input.action_release("shoot")
	aiming_offset = Vector2.ZERO
