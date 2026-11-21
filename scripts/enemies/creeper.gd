extends Enemy
class_name Creeper
## Fast, self-destructs near the player for heavy damage.

var _fuse: float = -1.0

func _init() -> void:
	enemy_type = "creeper"
	max_health = 25
	move_speed = 3.6
	attack_damage = 35
	attack_range = 2.6
	attack_cooldown = 999.0
	body_color = Color(0.3, 0.75, 0.3)
	accent_color = Color(0.1, 0.3, 0.1)
	score_value = 20
	is_ranged = false


func _ai(delta: float, target: Node3D) -> void:
	super._ai(delta, target)
	var dist := (target.global_position - global_position).length()
	if _fuse < 0.0 and dist <= attack_range:
		_fuse = 1.0
		Sfx.play_tone(600.0, 0.1, -8.0, 1)
	if _fuse >= 0.0:
		_fuse -= delta
		if _body_root:
			var s: float = 1.0 + (1.0 - clampf(_fuse, 0.0, 1.0)) * 0.4
			_body_root.scale = Vector3(s, s, s) * (3.0 if is_boss else 1.0)
		if _fuse <= 0.0:
			_explode(target)


func _explode(target: Node3D) -> void:
	_dead = true
	remove_from_group("enemies")
	var dist := (target.global_position - global_position).length()
	if dist <= attack_range + 1.5 and target.has_method("take_damage"):
		target.take_damage(attack_damage)
	Sfx.play_tone(80.0, 0.35, -3.0, 2)
	_spawn_death_particles()
	if Game:
		Game.add_score(score_value)
	died.emit(self)
	queue_free()
