extends Node

const VERSION: String = "0.1.0"

enum ItemMode {ACTIONABLE, USABLE, PASSIVE}
enum ItemClass {CANNON, MORTAR, BEAM, TORPEDO, SPEED_BOOST}
enum ModifierType {BUFF, DEBUFF}

func _init() -> void:
	ProjectSettings.set_setting("display/window/stretch/scale", DisplayServer.screen_get_scale())

func projectile_arc(x: float, distance: float, offset: float, max_range: float, min_angle: float, max_angle: float):
	# Keep maximum range the same with different angles
	var arc_range: float = max_range / tan(max_angle)
	
	# OH GLORIOUS Q - slope coefficient
	var slope = (offset + (pow(distance, 2.0) / arc_range)) / distance
	var q: float = max(min(slope, tan(max_angle)), tan(min_angle))
	
	return (-pow(x, 2.0) / arc_range) + (q * x)
