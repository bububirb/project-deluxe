class_name ArcFactory extends Object

static func create_cannon_arc(stats: ProjectileStats) -> CannonArc:
	return CannonArc.new(stats)

static func create_mortar_arc(stats: ProjectileStats) -> MortarArc:
	return MortarArc.new(stats)
