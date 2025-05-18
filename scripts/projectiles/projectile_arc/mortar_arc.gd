class_name MortarArc extends ProjectileArc

# Arc parameters
var arc_angle: float
var arc_range: float
var arc_slope: float

func _init(projectile_stats: ProjectileStats) -> void:
	stats = projectile_stats
	_calculate_arc()

func clamp_slope() -> MortarArc:
	arc_slope = max(min(arc_slope, tan(stats.ballistics.max_angle)), tan(stats.ballistics.min_angle))
	return self

func arc_height(x: float):
	return (-pow(x, 2.0) / arc_range) + (arc_slope * x)


func _calculate_arc() -> void:
	arc_angle = _calculate_arc_angle()
	arc_range = _calculate_arc_range()
	arc_slope = _calculate_arc_slope()

func _calculate_arc_angle() -> float:
	var angle = (asin(-stats.distance / stats.ballistics.max_range) + PI) / 2.0
	angle = max(min(angle, stats.ballistics.max_angle), stats.ballistics.min_angle)
	return angle

func _calculate_arc_range() -> float:
	return (2.0 * stats.ballistics.max_range * pow(cos(arc_angle), 2.0))

func _calculate_arc_slope() -> float:
	return tan(arc_angle)
