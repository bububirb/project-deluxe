extends Node

enum ItemMode {ACTIONABLE, USABLE, PASSIVE}
enum ItemClass {CANNON, MORTAR, SPEED_BOOST}

func projectile_arc(x: float, distance: float, offset: float, max_range: float, min_angle: float, max_angle: float):
	# Keep maximum range the same with different angles
	var range: float = max_range / tan(max_angle)
	
	# OH GLORIOUS Q - slope coefficient
	var slope = (offset + (pow(distance, 2.0) / range)) / distance
	var q: float = max(min(slope, tan(max_angle)), tan(min_angle))
	
	return (-pow(x, 2.0) / range) + (q * x)
