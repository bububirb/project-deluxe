extends Node

func _on_projectile_player_hit(player_id: int, attack: int) -> void:
	_deal_damage.rpc(player_id, attack)

@rpc("authority", "call_local", "reliable")
func _hit_test(hit_id: int) -> void:
	if multiplayer.get_unique_id() == hit_id:
		print(str(multiplayer.get_unique_id()),": I got hit!")
		get_player(hit_id).hud.trigger_health_effect()
	else:
		print(str(multiplayer.get_unique_id()),": ",str(hit_id)," got hit!")

@rpc("authority", "call_local", "reliable")
func _deal_damage(player_id: int, attack: int) -> void:
	var ship = get_player(player_id).ship
	var hud = get_player(player_id).hud
	if multiplayer.get_unique_id() == player_id:
		hud.trigger_health_effect()
	var damage: int = Math.calculate_damage(attack, ship.defense)
	ship.hp = ship.hp - damage
	hud.set_hp(ship.hp)

func get_game() -> Node3D:
	return get_tree().root.get_node("Game")

func get_player(player_id: int) -> Node3D:
	return get_game().get_node(str(player_id))

func get_players() -> Array[Node3D]:
	var players: Array[Node3D]
	for player_id: int in multiplayer.get_peers():
		var player: Node3D = get_player(player_id)
		if player:
			players.append(player)
	return players

func get_ships() -> Array[Ship]:
	var ships: Array[Ship]
	for player in get_players():
		ships.append(player.ship)
	return ships

func get_player_item(player_id: int, item_index: int) -> Node3D:
	var player = get_player(player_id)
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
	
	projectile_stats.position = ship.item_instancer.global_position
	projectile_stats.rotation.y = ship.item_instancer.global_rotation.y
	
	projectile_stats.distance = ship.aiming_distance
	projectile_stats.offset = ship.aiming_height_offset
	if item.item_class == Globals.ItemClass.CANNON:
		projectile_stats.height = item.stats.height * ship.aiming_distance / item.stats.max_range
	elif item.item_class == Globals.ItemClass.MORTAR:
		projectile_stats.height = item.stats.height
	projectile_stats.speed = item.stats.projectile_speed
	
	projectile_stats.attack = item.stats.attack
	
	_spawn_projectile.rpc(player_id, item_index, Marshalls.variant_to_base64(projectile_stats, true))
	
	reset_cooldown.rpc(player_id, item_index)

@rpc("authority", "call_local", "reliable")
func _spawn_projectile(player_id: int, item_index: int, projectile_stats) -> void:
	projectile_stats = Marshalls.base64_to_variant(projectile_stats, true)
	var projectile_instance: Projectile = get_player_item(player_id, item_index).projectile.instantiate()
	projectile_instance.stats = projectile_stats
	add_child(projectile_instance)
	projectile_instance.player_hit.connect(_on_projectile_player_hit)

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
	ship.speed_modifiers.append([item.stats.speed_boost, item.stats.duration])
	ship.nitro_particles.emitting = true

@rpc("authority", "call_local", "reliable")
func reset_cooldown(player_id: int, item_index: int) -> void:
	var ship: Ship = get_player(player_id).ship
	var item: Node = ship.get_item(item_index)
	get_player(player_id).hud.get_item(item_index).reset_cooldown()
	item.cooldown = item.stats.cooldown

@rpc("any_peer", "call_local", "reliable")
func set_visible_item(item_index: int) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	var player = get_player(player_id)
	if player:
		player.ship.set_visible_item(get_player_item(player_id, item_index))
