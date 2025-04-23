extends PanelContainer

@export var sprite: TextureRect
@export var cooldown_bar: ProgressBar
@export var selection_panel: Panel

@export var item: Item:
	set(new_item):
		item = new_item
		sprite.texture = item.sprite
		cooldown_bar.max_value = item.stats.cooldown
		cooldown_bar.value = 0.0

func select():
	selection_panel.show()

func deselect():
	selection_panel.hide()

func reset_cooldown():
	cooldown_bar.value = cooldown_bar.max_value
