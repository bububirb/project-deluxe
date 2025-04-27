extends Node

enum ItemMode {ACTIONABLE, USABLE, PASSIVE}
enum ItemClass {CANNON, MORTAR, SPEED_BOOST}

func projectile_arc(x: float, distance: float, height: float, offset: float):
	#hardcoded for now, need to be in definition later
	var maxrange : float =  45
	var maxangle : float = 35
	var minangle : float = -89
	
	#keeps maximum range the same with different angles
	var rangedivisor : float = maxrange / ( tan(maxangle))
	
	#OH GLORIOUS Q (slope coefficient)
	var requiredslope = ((offset) + (pow(distance,2) / rangedivisor)) / distance
	var q : float = max( min( requiredslope, tan(maxangle)), tan(minangle) )
	
	return ((-1 * x * x) / (rangedivisor)) + (q * x)
