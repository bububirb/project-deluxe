extends Control

const ACCUMULATION_RESET_TIME: float = 4.0
const ACUUMULATION_FADE_TIME: float = 0.5

const RESULTS_SCENE = preload("res://scenes/ui/results.tscn")

@export var local: Control
@export var remote: Control
@export var item_display: VBoxContainer
@export var vitals_overlay: TextureRect
@export var hp_bar: HPBar
@export var remote_hp_bar_container: CenterContainer
@export var remote_hp_bar: HPBar
@export var modifier_container: HBoxContainer
@export var damage_display: DamageDisplay
@export var accumulated_damage_label: DamageLabel
@export var name_label: Label
@export var game_over_panel: PanelContainer

var last_hit_time: float = 0.0
var accumulated_damage: int = 0
var accumulated_damage_tween: Tween

const ITEM_CONTAINER_SCENE = preload("res://scenes/ui/item_container.tscn")
const MODIFIER_DISPLAY_SCENE = preload("res://scenes/ui/modifier_display.tscn")

func get_item(index: int) -> PanelContainer:
	return item_display.get_child(index)

func _ready() -> void:
	accumulated_damage_label.modulate.a = 0.0
	name_label.text = MultiplayerLobby.players[get_multiplayer_authority()].name

func _process(delta: float) -> void:
	last_hit_time += delta
	if last_hit_time > ACCUMULATION_RESET_TIME:
		accumulated_damage = 0
		update_accumulated_damage_label()

func trigger_health_effect(health: int = 0):
	var overlay_color: Color = Color.RED
	if health >= 0:
		overlay_color = Color.GREEN
	var tween_1: PropertyTweener = create_tween().tween_property(vitals_overlay, "modulate", overlay_color, 0.05)
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

func set_hp(value: int, crit: bool = false, icon_path: String = "", id: int = -1) -> void:
	var damage: int = value - int(hp_bar.value)
	damage_display.display_damage(damage, crit, icon_path, id)
	
	last_hit_time = 0.0
	accumulated_damage += damage
	update_accumulated_damage_label()
	
	hp_bar.value = value
	remote_hp_bar.value = value

func game_over() -> void:
	if is_multiplayer_authority():
		game_over_panel.show()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func update_accumulated_damage_label() -> void:
	if accumulated_damage_tween:
		accumulated_damage_tween.kill()
		accumulated_damage_tween = null
	
	if accumulated_damage != 0:
		accumulated_damage_label.value = accumulated_damage
		accumulated_damage_label.modulate.a = 1.0
	else:
		accumulated_damage_tween = create_tween()
		accumulated_damage_tween.tween_property(accumulated_damage_label, "modulate:a", 0.0, ACUUMULATION_FADE_TIME)

func add_modifier(modifier: Modifier) -> void:
	var modifier_display = MODIFIER_DISPLAY_SCENE.instantiate()
	modifier_container.add_child(modifier_display)
	modifier_display.modifier = modifier

func _on_results_button_pressed() -> void:
	get_tree().change_scene_to_packed(RESULTS_SCENE)
