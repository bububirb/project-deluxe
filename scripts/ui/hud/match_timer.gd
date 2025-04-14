extends Label

var time_elapsed: float = 0.0
const MATCH_TIME: float = 300.0

func _ready() -> void:
	text = _convert_time(MATCH_TIME)

func _process(delta: float) -> void:
	time_elapsed += delta
	text = _convert_time(MATCH_TIME - time_elapsed)
	if time_elapsed > MATCH_TIME:
		process_mode = PROCESS_MODE_DISABLED

func _convert_time(time: float) -> String:
	var rounded_time: int = int(time)
	var seconds = rounded_time % 60
	var minutes = (rounded_time / 60) % 60
	
	#returns a string with the format "M:SS"
	return "%01d:%02d" % [minutes, seconds]
