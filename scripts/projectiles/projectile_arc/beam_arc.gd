class_name BeamArc extends ProjectileArc

# Arc parameters
var arc_range: float
var arc_slope: float

func _init(projectile_stats: ProjectileStats) -> void:
	stats = projectile_stats
	_calculate_arc()

func arc_height(x: float):
	return x * arc_slope


func _calculate_arc() -> void:
	arc_slope = _calculate_arc_slope()
	_clamp_slope()

func _calculate_arc_slope() -> float:
	return stats.offset / stats.distance

func _clamp_slope() -> BeamArc:
	arc_slope = max(min(arc_slope, tan(stats.max_angle)), tan(stats.min_angle))
	return self
