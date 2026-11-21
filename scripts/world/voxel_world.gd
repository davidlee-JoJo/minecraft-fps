extends Node3D
class_name VoxelWorld
## Procedurally generates a blocky Minecraft-style arena using MultiMesh.
## Each biome supplies a palette + layout config. Collision uses one StaticBody3D
## with box shapes (only for solid blocks on the surface layer to keep counts low).

@export var world_radius: int = 22
@export var ground_height: int = 1
@export var wall_height: int = 5

var biome: Dictionary = {}
var _blocks_root: Node3D
var _body: StaticBody3D


func build(config: Dictionary) -> void:
	biome = config
	_clear()
	_blocks_root = Node3D.new()
	_blocks_root.name = "Blocks"
	add_child(_blocks_root)
	_body = StaticBody3D.new()
	_body.name = "Collision"
	_body.collision_layer = 1
	_body.collision_mask = 0
	add_child(_body)

	_build_ground(config)
	_build_walls(config)
	_build_props(config)
	_build_lighting(config)


func _clear() -> void:
	for c in get_children():
		c.queue_free()


func _add_block_mesh(top: Color, side: Color, positions: Array, size: Vector3) -> void:
	if positions.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE
	mat.roughness = 0.95
	box.material = mat
	mm.mesh = box
	mm.instance_count = positions.size()
	for i in positions.size():
		var p: Vector3 = positions[i]
		var t := Transform3D(Basis.IDENTITY, p)
		mm.set_instance_transform(i, t)
		mm.set_instance_color(i, side)
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	_blocks_root.add_child(mmi)


func _add_collision_box(pos: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = pos
	_body.add_child(shape)


func _build_ground(config: Dictionary) -> void:
	var top_color: Color = config.get("top_color", Color(0.36, 0.72, 0.24))
	var side_color: Color = config.get("side_color", Color(0.45, 0.32, 0.18))
	var r: int = world_radius
	var top_positions: Array = []
	var side_positions: Array = []
	for x in range(-r, r + 1):
		for z in range(-r, r + 1):
			if x * x + z * z > r * r:
				continue
			top_positions.append(Vector3(x, 0, z))
			for y in range(1, ground_height + 1):
				side_positions.append(Vector3(x, -y, z))
	_add_block_mesh(top_color, top_color, top_positions, Vector3.ONE)
	_add_block_mesh(side_color, side_color, side_positions, Vector3.ONE)

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = r + 0.5
	cyl.height = float(ground_height + 1) * 2.0
	shape.shape = cyl
	shape.position = Vector3(0, -ground_height * 0.5, 0)
	_body.add_child(shape)


func _build_walls(config: Dictionary) -> void:
	var wall_color: Color = config.get("wall_color", Color(0.42, 0.42, 0.46))
	var r: int = world_radius
	var positions: Array = []
	var placed: Dictionary = {}
	for y in range(1, wall_height + 1):
		for a in range(0, 360, 3):
			var rad := deg_to_rad(float(a))
			var x := int(round(cos(rad) * r))
			var z := int(round(sin(rad) * r))
			var key := "%d,%d,%d" % [x, y, z]
			if placed.has(key):
				continue
			placed[key] = true
			positions.append(Vector3(x, y, z))
			_add_collision_box(Vector3(x, y, z), Vector3.ONE)
	_add_block_mesh(wall_color, wall_color, positions, Vector3.ONE)


func _build_props(config: Dictionary) -> void:
	var prop_color: Color = config.get("prop_color", Color(0.5, 0.5, 0.5))
	var count: int = config.get("prop_count", 12)
	var height_range: Array = config.get("prop_height", [1, 3])
	var r: int = world_radius - 4
	var positions: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config.get("seed", 1234))
	for i in count:
		var ang := rng.randf_range(0, TAU)
		var dist := rng.randf_range(4.0, float(r))
		var bx := int(round(cos(ang) * dist))
		var bz := int(round(sin(ang) * dist))
		var h := rng.randi_range(int(height_range[0]), int(height_range[1]))
		for y in range(1, h + 1):
			positions.append(Vector3(bx, y, bz))
		_add_collision_box(Vector3(bx, (h + 1) * 0.5, bz), Vector3(1, h, 1))
	_add_block_mesh(prop_color, prop_color, positions, Vector3.ONE)


func _build_lighting(config: Dictionary) -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_energy = config.get("sun_energy", 1.1)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var smat := ProceduralSkyMaterial.new()
	smat.sky_top_color = config.get("sky_top", Color(0.35, 0.55, 0.95))
	smat.sky_horizon_color = config.get("sky_horizon", Color(0.75, 0.85, 0.98))
	smat.ground_bottom_color = config.get("ground_horizon", Color(0.3, 0.35, 0.3))
	smat.ground_horizon_color = config.get("sky_horizon", Color(0.75, 0.85, 0.98))
	sky.sky_material = smat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = config.get("ambient", 0.6)
	e.fog_enabled = config.get("fog", false)
	if e.fog_enabled:
		e.fog_light_color = config.get("fog_color", Color(0.6, 0.6, 0.6))
		e.fog_density = 0.02
	env.environment = e
	add_child(env)
