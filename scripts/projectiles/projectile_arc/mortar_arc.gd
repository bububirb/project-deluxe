class_name MortarArc extends ProjectileArc

# Arc parameters
var a: float
var b: float
var c: float

func _init(projectile_stats: ProjectileStats) -> void:
	stats = projectile_stats
	_calculate_arc()

func arc_height(x: float):
	return (a * pow(x, 2.0) + b * x + c)

func _calculate_arc() -> void:
	a = -4 * stats.ballistics.height / pow(stats.distance, 2.0)
	b = 4 * stats.ballistics.height / stats.distance
	c = stats.offset / stats.distance
