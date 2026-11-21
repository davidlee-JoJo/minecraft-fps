extends Node3D
class_name Level
## Drives a single level: builds the voxel arena, spawns waves, tracks progress,
## and triggers level-complete / game-over.

signal wave_started(wave: int, total: int)
signal wave_cleared(wave: int)
signal enemies_remaining_changed(remaining: int)
signal level_cleared()
signal player_died_signal()

@export var level_index: int = 0
@export var level_name: String = "Level"
@export var biome_config: Dictionary = {}
@export var waves: Array = []
@export var is_boss_level: bool = false

var _world: VoxelWorld
var _player: Player
var _hud: CanvasLayer
var _spawn_timer: float = 0.0
var _pending_spawn: Array = []
var _current_wave: int = -1
var _alive: int = 0
var _cleared: bool = false
var _started: bool = false


func _ready() -> void:
	Game.current_level = level_index
	if biome_config.is_empty():
		biome_config = LevelsData.get_biome(level_index)
	if waves.is_empty() and not is_boss_level:
		waves = LevelsData.get_waves(level_index)
	if level_name.is_empty() or level_name == "Level":
		level_name = Game.get_level_name(level_index)
	_build_world()
	_spawn_player()
	_setup_hud()
	if is_boss_level:
		_start_boss()
	else:
		await get_tree().create_timer(1.0).timeout
		_start_next_wave()


func _build_world() -> void:
	_world = VoxelWorld.new()
	_world.name = "VoxelWorld"
	add_child(_world)
	_world.build(biome_config)


func _spawn_player() -> void:
	_player = load("res://scenes/player.tscn").instantiate() as Player
	add_child(_player)
	_player.global_position = Vector3(0, 2.0, 0)
	_player.add_to_group("player")
	_player.health_changed.connect(_on_player_health)
	_player.ammo_changed.connect(_on_player_ammo)
	_player.player_died.connect(_on_player_died)
	_player.hit_confirmed.connect(_on_hit_confirmed)


func _setup_hud() -> void:
	_hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child(_hud)
	_hud.setup(level_name, _player)
	wave_started.connect(_hud.show_wave)
	enemies_remaining_changed.connect(_hud.set_enemies_left)


func _on_player_health(cur: int, mx: int) -> void:
	if _hud:
		_hud.set_health(cur, mx)


func _on_player_ammo(mag: int, reserve: int) -> void:
	if _hud:
		_hud.set_ammo(mag, reserve)


func _on_hit_confirmed(killed: bool) -> void:
	if _hud:
		_hud.flash_hit(killed)


func _start_boss() -> void:
	wave_started.emit(1, 1)
	var boss := Boss.new()
	add_child(boss)
	boss.global_position = Vector3(0, 1.0, -12)
	boss.died.connect(_on_enemy_died)
	_alive = 1
	enemies_remaining_changed.emit(_alive)


func _start_next_wave() -> void:
	_current_wave += 1
	if _current_wave >= waves.size():
		_complete_level()
		return
	var wave: Dictionary = waves[_current_wave]
	wave_started.emit(_current_wave + 1, waves.size())
	var spawn_list: Array = []
	for entry in wave.get("enemies", []):
		for i in int(entry.get("count", 1)):
			spawn_list.append(entry.get("type", "zombie"))
	_pending_spawn = spawn_list
	_alive = spawn_list.size()
	enemies_remaining_changed.emit(_alive)
	_spawn_timer = 0.0
	_started = true


func _physics_process(delta: float) -> void:
	if _cleared or not _started:
		return
	if not _pending_spawn.is_empty():
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_timer = 0.6
			_spawn_one(_pending_spawn.pop_back())
		return
	var live := get_tree().get_nodes_in_group("enemies").filter(
		func(e): return is_instance_valid(e) and e.is_inside_tree() and e.get_parent() == self
	).size()
	_alive = live
	if live <= 0 and not is_boss_level:
		_started = false
		enemies_remaining_changed.emit(0)
		wave_cleared.emit(_current_wave + 1)
		await get_tree().create_timer(2.5).timeout
		if not _cleared:
			_start_next_wave()


func _spawn_one(type: String) -> void:
	var enemy: Enemy
	match type:
		"skeleton":
			enemy = Skeleton.new()
		"creeper":
			enemy = Creeper.new()
		_:
			enemy = Zombie.new()
	var ang := randf_range(0, TAU)
	var dist := randf_range(12.0, 18.0)
	var pos := Vector3(cos(ang) * dist, 1.0, sin(ang) * dist)
	add_child(enemy)
	enemy.global_position = pos
	enemy.died.connect(_on_enemy_died)


func _on_enemy_died(_e: Enemy) -> void:
	var live := get_tree().get_nodes_in_group("enemies").filter(
		func(e): return is_instance_valid(e) and e.is_inside_tree() and e.get_parent() == self
	).size()
	_alive = max(0, live)
	enemies_remaining_changed.emit(_alive)
	if is_boss_level and _alive <= 0:
		_complete_level()


func _complete_level() -> void:
	if _cleared:
		return
	_cleared = true
	Game.complete_level(level_index)
	level_cleared.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_show_overlay("關卡完成！", Color(0.5, 1, 0.5), _next_action)


func _on_player_died() -> void:
	player_died_signal.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_show_overlay("你死了…", Color(1, 0.3, 0.3), func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))


func _next_action() -> void:
	if level_index < 4:
		get_tree().change_scene_to_file("res://scenes/level_%02d.tscn" % (level_index + 2))
	elif level_index == 4:
		get_tree().change_scene_to_file("res://scenes/boss_level.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/victory.tscn")


func _show_overlay(text: String, color: Color, on_continue: Callable) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	var panel := ColorRect.new()
	panel.color = Color(0, 0, 0, 0.6)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(panel)
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 64)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 8)
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-300, -60)
	lbl.custom_minimum_size = Vector2(600, 0)
	layer.add_child(lbl)
	var btn := Button.new()
	btn.text = "繼續"
	btn.add_theme_font_size_override("font_size", 28)
	btn.set_anchors_preset(Control.PRESET_CENTER)
	btn.position = Vector2(-80, 40)
	btn.custom_minimum_size = Vector2(160, 56)
	btn.pressed.connect(on_continue)
	layer.add_child(btn)
