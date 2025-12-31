class_name CannonArc extends ProjectileArc

# Arc parameters
var arc_range: float
var arc_slope: float

func _init(init_trajectory: Trajectory, init_ballistics: Ballistics) -> void:
	trajectory = init_trajectory
	ballistics = init_ballistics
	_calculate_arc()

func arc_height(x: float):
	return (-pow(x, 2.0) / arc_range) + (arc_slope * x)


func _calculate_arc() -> void:
	arc_range = _calculate_arc_range()
	arc_slope = _calculate_arc_slope()
	_clamp_slope()

func _calculate_arc_range() -> float:
	# Keep maximum range the same with different angles
	return ballistics.max_range / tan(ballistics.max_angle)

func _calculate_arc_slope() -> float:
	return (trajectory.offset + (pow(trajectory.distance, 2.0) / arc_range)) / trajectory.distance

func _clamp_slope() -> CannonArc:
	arc_slope = max(min(arc_slope, tan(ballistics.max_angle)), tan(ballistics.min_angle))
	return self
