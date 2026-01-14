extends Node

const VERSION: String = "0.1.0"

enum ItemMode {ACTIONABLE, USABLE, PASSIVE}
enum ItemClass {CANNON, MORTAR, BEAM, TORPEDO, SPEED_BOOST}
enum ModifierType {BUFF, DEBUFF}

func _init() -> void:
	ProjectSettings.set_setting("display/window/stretch/scale", DisplayServer.screen_get_scale())

