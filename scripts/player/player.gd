extends CharacterBody3D
class_name Player
## First-person controller with mouse look, sprint, jump, health and a hitscan weapon.

signal health_changed(current: int, max_health: int)
signal ammo_changed(mag: int, reserve: int)
signal player_died()
signal hit_confirmed(killed: bool)

@export var speed: float = 6.5
@export var sprint_speed: float = 10.0
@export var jump_velocity: float = 6.0
@export var mouse_sensitivity: float = 0.0025
@export var max_health: int = 100

@export var fire_rate: float = 0.14
@export var damage: int = 25
@export var mag_size: int = 30
@export var reload_time: float = 1.4
@export var max_reserve: int = 180

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var health: int
var mag: int
var reserve: int
var _can_shoot: bool = true
var _reloading: bool = false
var _dead: bool = false
var _bob_time: float = 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon: Node3D = $Head/Camera3D/Weapon
@onready var muzzle: Marker3D = $Head/Camera3D/Weapon/Muzzle


func _ready() -> void:
	health = max_health
	mag = mag_size
	reserve = max_reserve
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health_changed.emit(health, max_health)
	ammo_changed.emit(mag, reserve)


func _unhandled_input(event: InputEvent) -> void:
	if _dead:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
	elif event.is_action_pressed("reload"):
		start_reload()
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if _dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Vector2.ZERO
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var cur_speed := sprint_speed if Input.is_action_pressed("sprint") else speed
	if direction:
		velocity.x = direction.x * cur_speed
		velocity.z = direction.z * cur_speed
	else:
		velocity.x = move_toward(velocity.x, 0, cur_speed)
		velocity.z = move_toward(velocity.z, 0, cur_speed)

	move_and_slide()
	_update_weapon_bob(delta, direction.length())

	if Input.is_action_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		try_shoot()


func _update_weapon_bob(delta: float, moving: float) -> void:
	if moving > 0.1 and is_on_floor():
		_bob_time += delta * 10.0
	else:
		_bob_time = lerp(_bob_time, 0.0, delta * 8.0)
	var bob := sin(_bob_time) * 0.02
	weapon.position.y = -0.25 + bob
	weapon.position.x = 0.28 + cos(_bob_time * 0.5) * 0.01


func try_shoot() -> void:
	if _dead or _reloading or not _can_shoot:
		return
	if mag <= 0:
		start_reload()
		return
	_can_shoot = false
	mag -= 1
	ammo_changed.emit(mag, reserve)
	_shoot_ray()
	get_tree().create_timer(fire_rate).timeout.connect(func(): _can_shoot = true)


func _shoot_ray() -> void:
	var space := get_world_3d().direct_space_state
	var origin := camera.global_position
	var end := origin + (-camera.global_transform.basis.z) * 200.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1 | 4
	query.exclude = [get_rid()]
	var result := space.intersect_ray(query)
	Sfx.play_tone(180.0, 0.08, -8.0, 2)
	if result:
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			var killed: bool = collider.take_damage(damage)
			hit_confirmed.emit(killed)
		_spawn_impact(result.position)


func _spawn_impact(pos: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 8
	p.lifetime = 0.4
	p.explosiveness = 1.0
	p.direction = Vector3.UP
	p.spread = 60.0
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 5.0
	p.gravity = Vector3(0, -9, 0)
	p.scale_amount_min = 0.04
	p.scale_amount_max = 0.1
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	p.mesh = mesh
	Game.get_spawn_root().add_child(p)
	p.global_position = pos
	p.finished.connect(func(): p.queue_free())


func start_reload() -> void:
	if _reloading or mag >= mag_size or reserve <= 0 or _dead:
		return
	_reloading = true
	Sfx.play_tone(300.0, 0.1, -10.0, 1)
	await get_tree().create_timer(reload_time).timeout
	if _dead:
		return
	var need := mag_size - mag
	var take := mini(need, reserve)
	mag += take
	reserve -= take
	_reloading = false
	ammo_changed.emit(mag, reserve)


func take_damage(amount: int) -> void:
	if _dead:
		return
	health = max(0, health - amount)
	health_changed.emit(health, max_health)
	Sfx.play_tone(140.0, 0.12, -6.0, 2)
	if health <= 0:
		_die()


func heal(amount: int) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)


func add_ammo(amount: int) -> void:
	reserve = min(max_reserve, reserve + amount)
	ammo_changed.emit(mag, reserve)


func _die() -> void:
	_dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player_died.emit()


func is_dead() -> bool:
	return _dead
