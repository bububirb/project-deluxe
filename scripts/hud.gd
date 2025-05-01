extends Control

@export var item_display: VBoxContainer
@export var vitals_overlay: TextureRect
@export var hp_bar: ProgressBar
@export var modifier_container: HBoxContainer

const ITEM_CONTAINER_SCENE = preload("res://scenes/ui/item_container.tscn")
const MODIFIER_DISPLAY_SCENE = preload("res://scenes/ui/modifier_display.tscn")

func get_item(index: int) -> PanelContainer:
	return item_display.get_child(index)

func _ready() -> void:
	var authority = get_multiplayer_authority()
	var player_name = multiplayer.get_unique_id()
	if not authority == player_name:
		hide()
		return

func trigger_health_effect(_health: int = 0):
	var tween_1: PropertyTweener = create_tween().tween_property(vitals_overlay, "modulate", Color.RED, 0.05)
	await tween_1.finished
	var _tween_2: PropertyTweener = create_tween().tween_property(vitals_overlay, "modulate", Color.TRANSPARENT, 1.5)

func _on_ship_item_selected(item: Node) -> void:
	var item_index = item.get_index()
	for item_container in item_display.get_children():
		item_container.deselect()
	get_item(item_index).select()

func _on_ship_item_executed(item: Node) -> void:
	var item_index = item.get_index()
	get_item(item_index).reset_cooldown()

func _on_ship_item_instanced(item: Item) -> void:
	var item_container = ITEM_CONTAINER_SCENE.instantiate()
	item_display.add_child(item_container)
	item_container.item = item

func set_hp(value: int) -> void:
	hp_bar.value = value

func add_modifier(modifier: Modifier) -> void:
	var modifier_display = MODIFIER_DISPLAY_SCENE.instantiate()
	modifier_container.add_child(modifier_display)
	modifier_display.modifier = modifier
