extends CharacterBody3D
class_name Enemy
## Base blocky enemy. Subclasses configure stats/behavior via exported fields.
## Builds its own voxel-ish body from boxes so no scene art is needed.

signal died(enemy: Enemy)

@export var enemy_type: String = "zombie"
@export var max_health: int = 50
@export var move_speed: float = 2.4
@export var attack_damage: int = 10
@export var attack_range: float = 1.8
@export var attack_cooldown: float = 1.0
@export var body_color: Color = Color(0.2, 0.55, 0.25)
@export var accent_color: Color = Color(0.25, 0.35, 0.6)
@export var score_value: int = 10
@export var is_ranged: bool = false
@export var projectile_speed: float = 18.0
@export var is_boss: bool = false

var health: int
var _attack_timer: float = 0.0
var _dead: bool = false
var _player: Node3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

var _body_root: Node3D
var _hit_flash: float = 0.0


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1
	_build_body()


func _build_body() -> void:
	_body_root = Node3D.new()
	add_child(_body_root)

	var torso := MeshInstance3D.new()
	var torso_mesh := BoxMesh.new()
	torso_mesh.size = Vector3(0.7, 0.8, 0.4)
	torso_mesh.material = _mat(body_color)
	torso.mesh = torso_mesh
	torso.position = Vector3(0, 1.0, 0)
	_body_root.add_child(torso)

	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(0.5, 0.5, 0.5)
	head_mesh.material = _mat(body_color.lightened(0.1))
	head.mesh = head_mesh
	head.position = Vector3(0, 1.65, 0)
	_body_root.add_child(head)

	var eye_l := MeshInstance3D.new()
	var eye_mesh := BoxMesh.new()
	eye_mesh.size = Vector3(0.12, 0.12, 0.06)
	eye_mesh.material = _mat(accent_color, true)
	eye_l.mesh = eye_mesh
	eye_l.position = Vector3(-0.13, 1.7, 0.26)
	_body_root.add_child(eye_l)
	var eye_r := eye_l.duplicate()
	eye_r.position = Vector3(0.13, 1.7, 0.26)
	_body_root.add_child(eye_r)

	var leg_l := MeshInstance3D.new()
	var leg_mesh := BoxMesh.new()
	leg_mesh.size = Vector3(0.25, 0.6, 0.25)
	leg_mesh.material = _mat(accent_color.darkened(0.2))
	leg_l.mesh = leg_mesh
	leg_l.position = Vector3(-0.18, 0.3, 0)
	_body_root.add_child(leg_l)
	var leg_r := leg_l.duplicate()
	leg_r.position = Vector3(0.18, 0.3, 0)
	_body_root.add_child(leg_r)

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.9
	col.shape = shape
	col.position = Vector3(0, 0.95, 0)
	add_child(col)

	if is_boss:
		_body_root.scale = Vector3(3.0, 3.0, 3.0)


func _mat(color: Color, emissive: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	if emissive:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 2.0
	return m


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_attack_timer = max(0.0, _attack_timer - delta)
	_hit_flash = max(0.0, _hit_flash - delta * 4.0)

	if not _player or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if _player:
		_ai(delta, _player)

	move_and_slide()


func _ai(delta: float, target: Node3D) -> void:
	var to_target := target.global_position - global_position
	to_target.y = 0
	var dist := to_target.length()
	if dist > 0.05:
		var dir := to_target.normalized()
		look_at(global_position + dir, Vector3.UP)
		if dist > attack_range * 0.9:
			velocity.x = dir.x * move_speed
			velocity.z = dir.z * move_speed
		else:
			velocity.x = 0
			velocity.z = 0
			if _attack_timer <= 0.0:
				_attack(target)
	else:
		velocity.x = 0
		velocity.z = 0


func _attack(target: Node3D) -> void:
	_attack_timer = attack_cooldown
	if is_ranged:
		_fire_projectile(target)
	else:
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
		Sfx.play_tone(200.0, 0.08, -8.0, 1)


func _fire_projectile(target: Node3D) -> void:
	var proj := Projectile.new()
	proj.damage = attack_damage
	proj.speed = projectile_speed
	proj.color = accent_color
	Game.get_spawn_root().add_child(proj)
	proj.global_position = global_position + Vector3(0, 1.4, 0)
	var dir := (target.global_position + Vector3(0, 1.0, 0) - proj.global_position).normalized()
	proj.setup(dir)
	Sfx.play_tone(420.0, 0.06, -10.0, 1)


func take_damage(amount: int) -> bool:
	if _dead:
		return false
	health -= amount
	_hit_flash = 1.0
	Sfx.play_tone(160.0, 0.05, -12.0, 2)
	if health <= 0:
		_die()
		return true
	return false


func _die() -> void:
	_dead = true
	remove_from_group("enemies")
	died.emit(self)
	if Game:
		Game.add_score(score_value)
	_spawn_death_particles()
	queue_free()


func _spawn_death_particles() -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 24 if is_boss else 14
	p.lifetime = 0.7
	p.explosiveness = 1.0
	p.direction = Vector3.UP
	p.spread = 180.0
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 6.0
	p.gravity = Vector3(0, -12, 0)
	p.scale_amount_min = 0.06
	p.scale_amount_max = 0.16
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	var mat := StandardMaterial3D.new()
	mat.albedo_color = body_color
	mesh.material = mat
	p.mesh = mesh
	Game.get_spawn_root().add_child(p)
	p.global_position = global_position + Vector3(0, 1.0, 0)
	p.finished.connect(func(): p.queue_free())
