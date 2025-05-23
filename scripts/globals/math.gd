extends Node

func calculate_damage(attack: int, ship: Ship) -> int:
	var attack_f: float = attack
	var defense_f: float = ship.get_defense()
	var damage: int = roundi(attack_f * attack_f / (defense_f + attack_f * 0.5))
	damage = min(damage, ship.hp)
	return damage

func calculate_healing(healing: int, ship: Ship) -> int:
	return min(healing, ship.max_hp - ship.hp)
