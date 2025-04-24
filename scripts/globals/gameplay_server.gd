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
