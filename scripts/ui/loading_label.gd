extends Label

var interval: float = 0.5
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	if time >= interval:
		time = 0.0
		text += "."
		if text.length() > 3:
			text = "."
