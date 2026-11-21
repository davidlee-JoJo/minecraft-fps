extends RefCounted
class_name LevelsData
## Static definitions for the 5 themed levels + boss arena.

static func get_biome(index: int) -> Dictionary:
	match index:
		0:
			return {
				"top_color": Color(0.36, 0.72, 0.24),
				"side_color": Color(0.45, 0.32, 0.18),
				"wall_color": Color(0.5, 0.45, 0.4),
				"prop_color": Color(0.3, 0.55, 0.2),
				"prop_count": 14,
				"prop_height": [1, 3],
				"sun_energy": 1.2,
				"sky_top": Color(0.35, 0.55, 0.95),
				"sky_horizon": Color(0.75, 0.88, 0.98),
				"ambient": 0.6,
				"seed": 101,
			}
		1:
			return {
				"top_color": Color(0.88, 0.8, 0.5),
				"side_color": Color(0.78, 0.68, 0.42),
				"wall_color": Color(0.7, 0.6, 0.4),
				"prop_color": Color(0.6, 0.5, 0.3),
				"prop_count": 18,
				"prop_height": [1, 2],
				"sun_energy": 1.5,
				"sky_top": Color(0.5, 0.7, 0.95),
				"sky_horizon": Color(0.95, 0.9, 0.7),
				"ambient": 0.7,
				"seed": 202,
			}
		2:
			return {
				"top_color": Color(0.92, 0.95, 1.0),
				"side_color": Color(0.7, 0.75, 0.82),
				"wall_color": Color(0.8, 0.85, 0.92),
				"prop_color": Color(0.6, 0.8, 0.95),
				"prop_count": 16,
				"prop_height": [1, 4],
				"sun_energy": 0.9,
				"sky_top": Color(0.6, 0.7, 0.9),
				"sky_horizon": Color(0.85, 0.9, 0.98),
				"ambient": 0.75,
				"fog": true,
				"fog_color": Color(0.85, 0.9, 0.98),
				"seed": 303,
			}
		3:
			return {
				"top_color": Color(0.5, 0.15, 0.12),
				"side_color": Color(0.4, 0.1, 0.08),
				"wall_color": Color(0.35, 0.08, 0.06),
				"prop_color": Color(0.9, 0.35, 0.1),
				"prop_count": 20,
				"prop_height": [1, 3],
				"sun_energy": 0.7,
				"sky_top": Color(0.35, 0.05, 0.05),
				"sky_horizon": Color(0.75, 0.25, 0.1),
				"ground_horizon": Color(0.4, 0.05, 0.05),
				"ambient": 0.5,
				"fog": true,
				"fog_color": Color(0.5, 0.12, 0.08),
				"seed": 404,
			}
		4:
			return {
				"top_color": Color(0.85, 0.82, 0.55),
				"side_color": Color(0.75, 0.72, 0.45),
				"wall_color": Color(0.2, 0.18, 0.25),
				"prop_color": Color(0.15, 0.12, 0.2),
				"prop_count": 10,
				"prop_height": [2, 6],
				"sun_energy": 0.6,
				"sky_top": Color(0.08, 0.05, 0.12),
				"sky_horizon": Color(0.25, 0.15, 0.3),
				"ground_horizon": Color(0.15, 0.12, 0.18),
				"ambient": 0.45,
				"fog": true,
				"fog_color": Color(0.2, 0.12, 0.25),
				"seed": 505,
			}
		_:
			return get_biome(4)


static func get_waves(index: int) -> Array:
	match index:
		0:
			return [
				{"enemies": [{"type": "zombie", "count": 4}]},
				{"enemies": [{"type": "zombie", "count": 6}]},
				{"enemies": [{"type": "zombie", "count": 5}, {"type": "skeleton", "count": 2}]},
			]
		1:
			return [
				{"enemies": [{"type": "skeleton", "count": 4}]},
				{"enemies": [{"type": "zombie", "count": 4}, {"type": "skeleton", "count": 3}]},
				{"enemies": [{"type": "skeleton", "count": 6}, {"type": "zombie", "count": 3}]},
			]
		2:
			return [
				{"enemies": [{"type": "zombie", "count": 5}, {"type": "skeleton", "count": 2}]},
				{"enemies": [{"type": "creeper", "count": 3}, {"type": "skeleton", "count": 3}]},
				{"enemies": [{"type": "zombie", "count": 6}, {"type": "creeper", "count": 3}]},
			]
		3:
			return [
				{"enemies": [{"type": "creeper", "count": 4}, {"type": "zombie", "count": 4}]},
				{"enemies": [{"type": "skeleton", "count": 5}, {"type": "creeper", "count": 3}]},
				{"enemies": [{"type": "zombie", "count": 5}, {"type": "creeper", "count": 4}, {"type": "skeleton", "count": 3}]},
			]
		4:
			return [
				{"enemies": [{"type": "zombie", "count": 6}, {"type": "skeleton", "count": 4}]},
				{"enemies": [{"type": "creeper", "count": 5}, {"type": "skeleton", "count": 4}]},
				{"enemies": [{"type": "zombie", "count": 6}, {"type": "creeper", "count": 5}, {"type": "skeleton", "count": 4}]},
			]
		_:
			return [{"enemies": [{"type": "zombie", "count": 4}]}]
