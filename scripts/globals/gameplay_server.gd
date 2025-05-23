extends Node

const BURN_TICK_DURATION: float = 1.0
var burn_counter: float = 0.0

func _ready() -> void:
	set_process(false)

@rpc("authority", "call_local", "reliable")
func start() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if multiplayer.is_server():
		burn_counter += delta
		if burn_counter >= BURN_TICK_DURATION:
			burn_counter = 0.0
			_burn_tick()

func _burn_tick() -> void:
	for player_id: int in get_player_ids():
		var burn_modifiers: Array[BurnModifier] = get_ship(player_id).get_burn_modifiers()
		if burn_modifiers:
			var burn_damage: float = 0.0
			for modifier in get_ship(player_id).get_burn_modifiers():
				burn_damage += modifier.damage
			_deal_fire_damage.rpc(player_id, int(burn_damage))

func _on_projectile_player_hit(player_id: int, hit_id: int, attack: int, modifiers: Array[Modifier], tags: Array[Tag]) -> void:
	var damage: int = Math.calculate_damage(attack, get_ship(hit_id).get_defense())
	_apply_hit.rpc(player_id, hit_id, damage, ModifierFactory.encode_modifiers(modifiers), TagFactory.encode_tags(tags))

func _on_aoe_projectile_hit(player_id: int, position: Vector3, radius: float, attack: int, modifiers: Array[Modifier], tags: Array[Tag]) -> void:
	var area_strength: Dictionary = _get_area_strength(position, radius)
	area_strength.erase(player_id)
	for hit_id in area_strength.keys():
		var scaled_modifiers: Array[Modifier] = modifiers.duplicate()
		for modifier: Modifier in scaled_modifiers:
			if modifier.scalable_duration:
				modifier.duration *= area_strength[hit_id]
		var damage: int = Math.calculate_damage(attack * area_strength[hit_id], get_ship(hit_id).get_defense())
		_apply_hit.rpc(player_id, hit_id, damage, ModifierFactory.encode_modifiers(scaled_modifiers), TagFactory.encode_tags(tags))

@rpc("authority", "call_local", "reliable")
func _deal_fire_damage(player_id: int, damage: int) -> void:
	_deal_damage(player_id, damage)

func _deal_damage(player_id: int, damage: int) -> void:
	var ship: Ship = get_ship(player_id)
	var hud: Node = get_player(player_id).hud
	ship.hp -= damage
	hud.set_hp(ship.hp)

@rpc("authority", "call_local", "reliable")
func _hit_test(hit_id: int) -> void:
	if multiplayer.get_unique_id() == hit_id:
		print(str(multiplayer.get_unique_id()),": I got hit!")
		get_player(hit_id).hud.trigger_health_effect()
	else:
		print(str(multiplayer.get_unique_id()),": ",str(hit_id)," got hit!")

@rpc("authority", "call_local", "reliable")
func _apply_hit(player_id: int, hit_id: int, damage: int, encoded_modifiers: Array[Dictionary], encoded_tags: Array[Dictionary]) -> void:
	var ship: Ship = get_player(hit_id).ship
	var hud: Node = get_player(hit_id).hud
	if multiplayer.get_unique_id() == hit_id:
		hud.trigger_health_effect(-damage)
	_deal_damage(hit_id, damage)
	for encoded_modifier in encoded_modifiers:
		var modifier: Modifier = ModifierFactory.import_modifier(encoded_modifier)
		ship.add_modifier(modifier)
		hud.add_modifier(modifier)
	var tags: Array[Tag]
	for tag in encoded_tags:
		tags.append(TagFactory.import_tag(tag))
	for tag in tags:
		if tag is LeechRateTag:
			_apply_healing(player_id, damage * tag.amount, [], []) # TODO: Separate health effect from _apply_healing()

@rpc("authority", "call_local", "reliable")
func _apply_healing(player_id: int, healing: int, encoded_modifiers: Array[Dictionary], encoded_tags: Array[Dictionary]) -> void:
	var ship: Ship = get_player(player_id).ship
	var hud: Node = get_player(player_id).hud
	if multiplayer.get_unique_id() == player_id:
		hud.trigger_health_effect(healing)
	_heal(player_id, healing)
	for encoded_modifier in encoded_modifiers:
		var modifier: Modifier = ModifierFactory.import_modifier(encoded_modifier)
		ship.add_modifier(modifier)
		hud.add_modifier(modifier)
	var tags: Array[Tag]
	for tag in encoded_tags:
		tags.append(TagFactory.import_tag(tag))

func _heal(player_id: int, healing: int) -> void:
	var ship: Ship = get_ship(player_id)
	var hud: Node = get_player(player_id).hud
	ship.hp += healing
	hud.set_hp(ship.hp)

func _get_area_strength(position: Vector3, radius: float) -> Dictionary:
	var area_strength: Dictionary = {}
	for player_id: int in get_player_ids():
		var distance: float = position.distance_to(get_ship(player_id).position)
		if distance < radius:
			area_strength[player_id] = 1.0 - min(distance / radius, 1.0)
	return area_strength

func get_player_ids() -> PackedInt32Array:
	var player_ids: PackedInt32Array = multiplayer.get_peers()
	player_ids.append(multiplayer.get_unique_id())
	return player_ids

func get_game() -> Node3D:
	return get_tree().root.get_node("Game")

func get_player(player_id: int) -> Node3D:
	return get_game().get_node(str(player_id))

func get_players() -> Array[Node3D]:
	var players: Array[Node3D]
	for player_id: int in get_player_ids():
		var player: Node3D = get_player(player_id)
		if player:
			players.append(player)
	return players

func get_ship(player_id: int) -> Ship:
	return get_player(player_id).ship

func get_ships() -> Array[Ship]:
	var ships: Array[Ship]
	for player in get_players():
		ships.append(player.ship)
	return ships

func get_player_item(player_id: int, item_index: int) -> Node3D:
	var player: Node = get_player(player_id)
	if player:
		return player.ship.get_item(item_index)
	else:
		return null

@rpc("any_peer", "call_local", "reliable")
func shoot(player_id: int, item_index: int) -> void:
	var ship: Ship = get_player(player_id).ship
	var item: Node = get_player_item(player_id, item_index)
	if item.cooldown > 0.0: return
	
	var projectile_stats: ProjectileStats = ProjectileStats.new()
	
	var start_position: Vector3 = ship.item_instancer.global_position
	var target_position: Vector3 = ship.aiming_position
	
	var start_position_flat: Vector2 = Vector2(start_position.x, start_position.z)
	var target_position_flat: Vector2 = Vector2(target_position.x, target_position.z)
	
	projectile_stats.position = start_position
	projectile_stats.rotation.y = PI / 2.0 - (target_position_flat - start_position_flat).angle()
	projectile_stats.player_id = player_id
	
	projectile_stats.item_class = item.item_class
	projectile_stats.attack = item.stats.attack
	projectile_stats.radius = item.stats.radius
	projectile_stats.modifiers = item.stats.modifiers_on_hit.duplicate()
	projectile_stats.tags = item.stats.tags.duplicate()
	
	projectile_stats.distance = ship.aiming_distance
	projectile_stats.offset = ship.aiming_height_offset
	
	projectile_stats.ballistics = item.stats.ballistics
	
	#if item.item_class == Globals.ItemClass.CANNON:
		#projectile_stats.height = item.stats.height * ship.aiming_distance / item.stats.max_range
	#elif item.item_class == Globals.ItemClass.MORTAR:
		#projectile_stats.height = item.stats.height
	
	
	_spawn_projectile.rpc(player_id, item_index, Marshalls.variant_to_base64(projectile_stats, true))
	
	reset_cooldown.rpc(player_id, item_index)

@rpc("authority", "call_local", "reliable")
func _spawn_projectile(player_id: int, item_index: int, projectile_stats) -> void:
	projectile_stats = Marshalls.base64_to_variant(projectile_stats, true)
	var projectile_instance: Projectile = get_player_item(player_id, item_index).projectile.instantiate()
	projectile_instance.stats = projectile_stats
	add_child(projectile_instance)
	#projectile_instance.player_hit.connect(_on_projectile_player_hit)

@rpc("any_peer", "call_local", "reliable")
func boost(player_id, item_index) -> void:
	var item: Node = get_player_item(player_id, item_index)
	if item.cooldown > 0.0: return
	
	_add_speed_boost.rpc(player_id, item_index)
	reset_cooldown.rpc(player_id, item_index)

@rpc("authority", "call_local", "reliable")
func _add_speed_boost(player_id, item_index) -> void:
	var ship: Ship = get_player(player_id).ship
	var item: Node = get_player_item(player_id, item_index)
	var hud: Node = get_player(player_id).hud
	
	var new_modifier = item.stats.modifier.duplicate()
	ship.modifiers.append(new_modifier)
	hud.add_modifier(new_modifier)
	ship.nitro_particles.emitting = true

@rpc("authority", "call_local", "reliable")
func reset_cooldown(player_id: int, item_index: int) -> void:
	var ship: Ship = get_ship(player_id)
	var item: Node = ship.get_item(item_index)
	get_player(player_id).hud.get_item(item_index).reset_cooldown()
	item.cooldown = item.stats.cooldown

@rpc("any_peer", "call_local", "reliable")
func set_visible_item(item_index: int) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	var player = get_player(player_id)
	if player:
		player.ship.set_visible_item(get_player_item(player_id, item_index))
