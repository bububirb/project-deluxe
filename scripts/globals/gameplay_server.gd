extends Node

const BURN_TICK_DURATION: float = 1.0
const SHIPWRECK_TICK_DURATION: float = 1.0
const SHIPWRECK_DAMAGE: int = 500

var damage_dealt: Dictionary[int, int] = {}

func _ready() -> void:
	stop()

@rpc("authority", "call_local", "reliable")
func start() -> void:
	set_process(true)

func stop() -> void:
	set_process(false)

func _on_projectile_player_hit(player_id: int, hit_id: int, attack: int, modifiers: Array[Modifier], tags: Array[Tag]) -> void:
	var damage: int = Math.calculate_damage(attack, get_ship(hit_id))
	var crit: bool = false
	
	for tag in tags:
		if tag is CritTag:
			if tag.crit_chance > randf():
				damage *= 1.0 + tag.crit_chance
				crit = true
	
	for tag in tags:
		if tag is LeechRateTag and player_id != 0:
			_apply_healing.rpc(player_id, damage * tag.amount)
	
	#_synchronize_hp.rpc(hit_id, get_ship(hit_id).hp)
	_apply_hit.rpc(player_id, hit_id, damage, crit, ModifierFactory.encode_modifiers(modifiers))

func _on_aoe_projectile_hit(player_id: int, position: Vector3, radius: float, attack: int, modifiers: Array[Modifier], tags: Array[Tag]) -> void:
	var area_strength: Dictionary = _get_area_strength(position, radius)
	area_strength.erase(player_id)
	for hit_id in area_strength.keys():
		var scaled_modifiers: Array[Modifier] = modifiers.duplicate()
		for modifier: Modifier in scaled_modifiers:
			if modifier.scalable_duration:
				modifier.duration *= area_strength[hit_id]
		var damage: int = Math.calculate_damage(attack * area_strength[hit_id], get_ship(hit_id))
		var crit: bool = false
		
		for tag in tags:
			if tag is CritTag:
				if tag.crit_chance > randf():
					damage *= 1.0 + tag.crit_chance
					crit = true
		
		for tag in tags:
			if tag is LeechRateTag and player_id != 0:
				_apply_healing.rpc(player_id, damage * tag.amount)
		
		#_synchronize_hp.rpc(hit_id, get_ship(hit_id).hp)
		_apply_hit.rpc(player_id, hit_id, damage, crit, ModifierFactory.encode_modifiers(scaled_modifiers))

func _on_shipwreck_tick(hit_id: int, player_ids: Array[int], attack: int) -> void:
	var damage = Math.calculate_damage(attack, get_ship(hit_id))
	for player_id in player_ids:
		_deal_shipwreck_damage.rpc(player_id, hit_id, damage)

@rpc("authority", "call_remote", "reliable")
func _synchronize_hp(player_id: int, hp: int) -> void:
	get_ship(player_id).hp = hp

@rpc("authority", "call_local", "reliable")
func _deal_burn_damage(hit_id: int, modifier: BurnModifier) -> void:
	var burn_damage = Math.calculate_damage(modifier.damage, get_ship(hit_id))
	_deal_damage(modifier.player_id, hit_id, burn_damage, false, modifier.icon_path, modifier.get_instance_id())

@rpc("authority", "call_local", "reliable")
func _deal_shipwreck_damage(player_id: int, hit_id: int, damage: int) -> void:
	_deal_damage(player_id, hit_id, damage)

func _deal_damage(player_id: int, hit_id: int, damage: int, crit: bool = false, icon_path: String = "", id: int = -1) -> void:
	if not get_ship(hit_id).alive: return
	var ship: Ship = get_ship(hit_id)
	var hud: Node = get_player(hit_id).hud
	ship.hp -= damage
	hud.set_hp(ship.hp, crit, icon_path, id)
	count_damage(player_id, damage)
	if ship.hp <= 0:
		ship.kill()
		if multiplayer.is_server():
			if get_alive_players().size() <= 1:
				game_over.rpc()

@rpc("authority", "call_local", "reliable")
func _hit_test(hit_id: int) -> void:
	if multiplayer.get_unique_id() == hit_id:
		print(str(multiplayer.get_unique_id()),": I got hit!")
		get_player(hit_id).hud.trigger_health_effect()
	else:
		print(str(multiplayer.get_unique_id()),": ",str(hit_id)," got hit!")

@rpc("authority", "call_local", "reliable")
func _apply_hit(player_id: int, hit_id: int, damage: int, crit: bool = false, encoded_modifiers: Array[Dictionary] = []) -> void:
	var ship: Ship = get_player(hit_id).ship
	var hud: Node = get_player(hit_id).hud
	if multiplayer.get_unique_id() == hit_id:
		hud.trigger_health_effect(-damage)
	_deal_damage(player_id, hit_id, damage, crit)
	for encoded_modifier in encoded_modifiers:
		var modifier: Modifier = ModifierFactory.import_modifier(encoded_modifier)
		if modifier.get("player_id"):
			modifier.player_id = player_id
		ship.add_modifier(modifier)
		hud.add_modifier(modifier)

@rpc("authority", "call_local", "reliable")
func _apply_healing(player_id: int, healing: int, encoded_modifiers: Array[Dictionary] = []) -> void:
	var ship: Ship = get_player(player_id).ship
	var hud: Node = get_player(player_id).hud
	if multiplayer.get_unique_id() == player_id:
		hud.trigger_health_effect(healing)
	_heal(player_id, healing)
	for encoded_modifier in encoded_modifiers:
		var modifier: Modifier = ModifierFactory.import_modifier(encoded_modifier)
		ship.add_modifier(modifier)
		hud.add_modifier(modifier)

func _heal(player_id: int, healing: int) -> void:
	var ship: Ship = get_ship(player_id)
	var hud: Node = get_player(player_id).hud
	ship.hp += Math.calculate_healing(healing, ship)
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

func get_alive_players() -> Array[int]:
	var alive_players: Array[int] = []
	for player_id in get_player_ids():
		if get_ship(player_id).alive:
			alive_players.append(player_id)
	return alive_players

func get_player_item(player_id: int, item_index: int) -> Node3D:
	var player: Node = get_player(player_id)
	if player:
		return player.ship.get_item(item_index)
	else:
		return null

func count_damage(player_id: int, damage: int) -> void:
	get_ship(player_id).damage_dealt += damage

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

@rpc("authority", "call_local", "reliable")
func game_over() -> void:
	var hud: Node = get_player(multiplayer.get_unique_id()).hud
	hud.game_over()
	for player_id in get_player_ids():
		damage_dealt[player_id] = get_ship(player_id).damage_dealt
