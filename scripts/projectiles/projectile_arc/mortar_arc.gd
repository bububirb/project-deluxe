class_name MortarArc extends ProjectileArc

# Arc parameters
var a: float
var b: float
var c: float
var distance: float

func _init(init_trajectory: Trajectory, init_ballistics: Ballistics) -> void:
	trajectory = init_trajectory
	ballistics = init_ballistics
	_calculate_arc()

func arc_height(x: float):
	return (a * pow(x, 2.0) + b * x + c)

func _calculate_arc() -> void:
	distance = clampf(trajectory.distance, ballistics.min_range, ballistics.max_range)
	a = -4 * ballistics.height / pow(distance, 2.0)
	b = 4 * ballistics.height / distance
	c = trajectory.offset / distance
