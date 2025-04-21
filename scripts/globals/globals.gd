extends Node

enum ItemMode {ACTIONABLE, USABLE, PASSIVE}

func projectile_arc(time: float, distance: float, height: float, offset: float):
	# (x(4hr - 4hx + rv))/r^2
	return (time * ((4 * height * distance) - (4 * height * time) + (distance * offset))) / pow(distance, 2.0)
