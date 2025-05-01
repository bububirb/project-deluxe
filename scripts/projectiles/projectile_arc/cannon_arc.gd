class_name CannonArc extends ProjectileArc

# Arc parameters
var arc_range: float
var arc_slope: float

func _init(projectile_stats: ProjectileStats) -> void:
	stats = projectile_stats
	_calculate_arc()

func arc_height(x: float):
	return (-pow(x, 2.0) / arc_range) + (arc_slope * x)


func _calculate_arc() -> void:
	arc_range = _calculate_arc_range()
	arc_slope = _calculate_arc_slope()
	_clamp_slope()

func _calculate_arc_range() -> float:
	# Keep maximum range the same with different angles
	return stats.max_range / tan(stats.max_angle)

func _calculate_arc_slope() -> float:
	return (stats.offset + (pow(stats.distance, 2.0) / arc_range)) / stats.distance

func _clamp_slope() -> CannonArc:
	arc_slope = max(min(arc_slope, tan(stats.max_angle)), tan(stats.min_angle))
	return self
