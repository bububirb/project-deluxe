extends PanelContainer

@export var name_label: Label
@export var damage_label: Label

func set_player_name(player_name: String) -> void:
	name_label.text = player_name

func set_damage(damage: int) -> void:
	damage_label.text = str(damage)
