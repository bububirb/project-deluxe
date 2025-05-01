class_name WeaponStats extends Stats

@export var attack: float
@export var cooldown: float
@export var radius: float

@export_group("Ballistics")
@export var projectile_speed: float
@export var max_range: float
@export_range(-90, 90, 0.1, "radians_as_degrees") var min_angle: float
@export_range(-90, 90, 0.1, "radians_as_degrees") var max_angle: float

@export_group("Modifiers", "modifiers_")
@export var modifiers_on_use: Array[Modifier] # List of modifiers to apply on self when used
@export var modifiers_on_hit: Array[Modifier] # List of modifiers to apply on target when hit

@export_group("Deprecated")
@export var height: float
