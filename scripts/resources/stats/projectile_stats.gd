class_name ProjectileStats extends Resource

@export var position: Vector3
@export var rotation: Vector3
@export var player_id: int

@export var item_class: Globals.ItemClass
@export var attack: int
@export var modifiers: Array[Modifier]

# Ballistics
@export var distance: float
@export var offset: float
@export var ballistics: Ballistics

# Deprecated
@export var height: float
