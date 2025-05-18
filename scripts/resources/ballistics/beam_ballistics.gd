class_name BeamBallistics extends Ballistics

@export var projectile_speed: float = 30.0
@export_range(-90, 90, 0.1, "radians_as_degrees") var min_angle: float
@export_range(-90, 90, 0.1, "radians_as_degrees") var max_angle: float
