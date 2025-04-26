extends Node

enum ItemMode {ACTIONABLE, USABLE, PASSIVE}
enum ItemClass {CANNON, MORTAR, SPEED_BOOST}

func projectile_arc(x: float, distance: float, height: float, offset: float):
	# (x(4hr - 4hx + rv))/r^2
	return (x * ((4 * height * distance) - (4 * height * x) + (distance * offset))) / pow(distance, 2.0)
