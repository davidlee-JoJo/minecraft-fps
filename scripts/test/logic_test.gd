extends SceneTree
## Logic test: instantiate each level, continuously kill enemies, verify each level
## reaches level_cleared and that the next level becomes unlocked.

var _level: Node = null
var _current_index: int = 0
var _cleared_count: int = 0
var _frame: int = 0
var _timeout: int = 0
var _game: Node = null
var _started := false


func _initialize() -> void:
	print("LOGIC: begin")


func _get_game() -> Node:
	return get_root().get_node_or_null("Game")


var _elapsed: float = 0.0


func _process(delta: float) -> bool:
	if not _started:
		_game = _get_game()
		if _game == null:
			return false
		print("LOGIC: found Game autoload")
		_game.unlocked_levels.assign([0])
		_started = true
		_start_level(0)
		return false
	if _level == null:
		return false
	_frame += 1
	_elapsed += delta
	for e in get_nodes_in_group("enemies"):
		if is_instance_valid(e) and e.has_method("take_damage"):
			e.take_damage(99999)
	if _elapsed > 120.0:
		print("LOGIC: TIMEOUT on level ", _current_index)
		var lvl = _level
		if "waves" in lvl:
			print("  waves: ", lvl.waves.size(), " current: ", lvl._current_wave, " alive: ", lvl._alive, " pending: ", lvl._pending_spawn.size(), " started: ", lvl._started, " timer: ", lvl._spawn_timer, " cleared: ", lvl._cleared)
		quit(1)
	return false


func _start_level(index: int) -> void:
	if index > 4:
		print("LOGIC: cleared=", _cleared_count, " unlocked=", _game.unlocked_levels)
		if _cleared_count >= 5 and _game.unlocked_levels.has(5):
			print("LOGIC: ALL PASSED")
			quit(0)
		else:
			print("LOGIC: FAIL")
			quit(1)
		return
	_current_index = index
	var path := "res://scenes/level_%02d.tscn" % (index + 1)
	print("LOGIC: start level ", index)
	var packed := load(path)
	_level = packed.instantiate()
	get_root().add_child(_level)
	_level.level_cleared.connect(_on_cleared.bind(index))
	_timeout = 0
	_elapsed = 0.0


func _on_cleared(index: int) -> void:
	print("LOGIC: level ", index, " CLEARED, unlocked=", _game.unlocked_levels)
	_cleared_count += 1
	if is_instance_valid(_level):
		_level.queue_free()
	_level = null
	_start_level(index + 1)
