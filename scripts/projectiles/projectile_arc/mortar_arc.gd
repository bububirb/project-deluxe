class_name MortarArc extends ProjectileArc

# Arc parameters
var a: float
var b: float
var c: float
var distance: float

func _init(projectile_stats: ProjectileStats) -> void:
	stats = projectile_stats
	_calculate_arc()

func arc_height(x: float):
	return (a * pow(x, 2.0) + b * x + c)

func _calculate_arc() -> void:
	distance = clampf(stats.distance, stats.ballistics.min_range, stats.ballistics.max_range)
	a = -4 * stats.ballistics.height / pow(distance, 2.0)
	b = 4 * stats.ballistics.height / distance
	c = stats.offset / distance
