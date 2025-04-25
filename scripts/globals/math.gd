extends Node

func calculate_damage(attack: int, defense: int) -> int:
	var attack_f: float = attack
	var defense_f: float = defense
	return roundi(attack_f * attack_f / (defense_f + attack_f * 0.5))
