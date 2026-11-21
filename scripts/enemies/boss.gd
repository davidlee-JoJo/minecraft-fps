extends Enemy
class_name Boss
## Multi-phase giant block boss. Phases at 66% and 33% health.
## Attacks: charge melee, radial projectile burst, and summons minions.

var phase: int = 1
var _special_timer: float = 3.0
var _summon_timer: float = 8.0
var _enraged: bool = false


func _init() -> void:
	enemy_type = "boss"
	max_health = 1200
	move_speed = 2.0
	attack_damage = 25
	attack_range = 4.5
	attack_cooldown = 1.6
	body_color = Color(0.35, 0.1, 0.45)
	accent_color = Color(0.9, 0.2, 0.2)
	score_value = 500
	is_ranged = false
	is_boss = true


func _ready() -> void:
	super._ready()
	_build_crown()


func _build_crown() -> void:
	var crown := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3(1.2, 0.4, 1.2)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.7, 0.1)
	mat.emission_energy_multiplier = 1.5
	m.material = mat
	crown.mesh = m
	crown.position = Vector3(0, 2.05, 0)
	_body_root.add_child(crown)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	super._physics_process(delta)
	if _player and is_instance_valid(_player):
		_special_timer -= delta
		_summon_timer -= delta
		if _special_timer <= 0.0:
			_radial_burst(_player)
			_special_timer = 2.5 if _enraged else 4.0
		if _summon_timer <= 0.0:
			_summon_minions()
			_summon_timer = 10.0 if _enraged else 14.0


func take_damage(amount: int) -> bool:
	if _dead:
		return false
	health -= amount
	_hit_flash = 1.0
	Sfx.play_tone(120.0, 0.05, -12.0, 2)
	var pct := float(health) / float(max_health)
	if phase == 1 and pct <= 0.66:
		_enter_phase(2)
	elif phase == 2 and pct <= 0.33:
		_enter_phase(3)
	if health <= 0:
		_die()
		return true
	return false


func _enter_phase(p: int) -> void:
	phase = p
	_enraged = true
	move_speed += 1.2
	Sfx.play_tone(90.0, 0.5, -2.0, 0)
	_radial_burst(_player) if _player else null


func _radial_burst(target: Node3D) -> void:
	if not target:
		return
	var count := 12 + phase * 4
	for i in count:
		var ang := (TAU / count) * i
		var dir := Vector3(cos(ang), 0.15, sin(ang))
		var proj := Projectile.new()
		proj.damage = 12
		proj.speed = 14.0
		proj.color = accent_color
		Game.get_spawn_root().add_child(proj)
		proj.global_position = global_position + Vector3(0, 3.0, 0)
		proj.setup(dir)
	Sfx.play_tone(300.0, 0.2, -4.0, 2)


func _summon_minions() -> void:
	var n := 2 + phase
	for i in n:
		var ang := randf_range(0, TAU)
		var pos := global_position + Vector3(cos(ang) * 5.0, 0, sin(ang) * 5.0)
		var z := Zombie.new()
		Game.get_spawn_root().add_child(z)
		z.global_position = pos
	Sfx.play_tone(500.0, 0.25, -6.0, 1)
