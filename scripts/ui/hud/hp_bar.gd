@tool
class_name HPBar extends PanelContainer

@export var value: float = 0.0:
	set(new_value):
		value = new_value
		%Bar.value = value
		_update_label()

@export var max_value: float = 100.0:
	set(new_value):
		max_value = new_value
		%Bar.max_value = max_value
		_update_label()

func _update_label() -> void:
	%Label.text = str(int(value)) + "/" + str(int(max_value))
