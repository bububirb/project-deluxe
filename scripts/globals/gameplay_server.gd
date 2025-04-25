extends Node

func _on_projectile_player_hit(player_id: int) -> void:
	_hit_test.rpc(player_id)

@rpc("authority","call_local","reliable")
func _hit_test(hit_id: int) -> void:
	if multiplayer.get_unique_id() == hit_id:
		print(str(multiplayer.get_unique_id()),": I got hit!")
		get_player(hit_id).ship.projectile_hit.emit()
	else:
		print(str(multiplayer.get_unique_id()),": ",str(hit_id)," got hit!")

func get_player(player_id: int) -> Node3D:
	return get_tree().root.get_node("Game").get_node(str(player_id))

func get_player_item(player_id: int, item_index: int) -> Node3D:
	return get_player(player_id).ship.get_item(item_index)

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
	
	_spawn_projectile.rpc(player_id, item_index, Marshalls.variant_to_base64(projectile_stats, true))
	
	reset_cooldown.rpc(player_id, item_index)
	ship.item_executed.emit(self)

@rpc("authority", "call_local", "reliable")
func _spawn_projectile(player_id: int, item_index: int, projectile_stats) -> void:
	projectile_stats = Marshalls.base64_to_variant(projectile_stats, true)
	var projectile_instance: Projectile = get_player_item(player_id, item_index).projectile.instantiate()
	projectile_instance.stats = projectile_stats
	add_child(projectile_instance)
	projectile_instance.player_hit.connect(_on_projectile_player_hit)

@rpc("any_peer", "call_local", "reliable")
func boost(player_id, item_index) -> void:
	var ship: Ship = get_player(player_id).ship
	var item: Node = get_player_item(player_id, item_index)
	if item.cooldown > 0.0: return
	
	_add_speed_boost.rpc(player_id, item_index)
	ship.nitro_particles.emitting = true
	reset_cooldown.rpc(player_id, item_index)

@rpc("authority", "call_local", "reliable")
func _add_speed_boost(player_id, item_index) -> void:
	var ship: Ship = get_player(player_id).ship
	var item: Node = get_player_item(player_id, item_index)
	ship.speed_modifiers.append([item.stats.speed_boost, item.stats.duration])

@rpc("authority", "call_local", "reliable")
func reset_cooldown(player_id: int, item_index: int) -> void:
	var ship: Ship = get_player(player_id).ship
	var item: Node = ship.get_item(item_index)
	item.cooldown = item.stats.cooldown

@rpc("any_peer", "call_local", "reliable")
func set_visible_item(player_id: int, item_index: int) -> void:
	if player_id == multiplayer.get_remote_sender_id():
		get_player(player_id).ship.set_visible_item(get_player_item(player_id, item_index))
