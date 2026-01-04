@tool
class_name Line3D extends MeshInstance3D

var points: PackedVector3Array = []

func _init() -> void:
	mesh = ImmediateMesh.new()
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func call_redraw() -> void:
	_update()

func add_point(point: Vector3) -> void:
	points.append(point)

func _update() -> void:
	_draw_lines()

func _draw_lines() -> void:
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for point in points:
		mesh.surface_add_vertex(point)
	mesh.surface_end()

func clear() -> void:
	points = []
