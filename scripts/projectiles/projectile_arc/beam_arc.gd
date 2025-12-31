class_name BeamArc extends ProjectileArc

# Arc parameters
var arc_range: float
var arc_slope: float

func _init(init_trajectory: Trajectory, init_ballistics: Ballistics) -> void:
	trajectory = init_trajectory
	ballistics = init_ballistics
	_calculate_arc()

func arc_height(x: float):
	return x * arc_slope

func _calculate_arc() -> void:
	arc_slope = _calculate_arc_slope()
	_clamp_slope()

func _calculate_arc_slope() -> float:
	return trajectory.offset / trajectory.distance

func _clamp_slope() -> BeamArc:
	arc_slope = max(min(arc_slope, tan(ballistics.max_angle)), tan(ballistics.min_angle))
	return self
