extends SceneTree
## Boss test: load boss level, kill boss, verify level_cleared fires.

var _level: Node = null
var _game: Node = null
var _started := false
var _elapsed := 0.0
var _done := false


func _initialize() -> void:
	print("BOSSTEST: begin")


func _process(delta: float) -> bool:
	if not _started:
		_game = get_root().get_node_or_null("Game")
		if _game == null:
			return false
		_level = load("res://scenes/boss_level.tscn").instantiate()
		get_root().add_child(_level)
		_level.level_cleared.connect(_on_cleared)
		_started = true
		return false
	if _done:
		return false
	_elapsed += delta
	for e in get_nodes_in_group("enemies"):
		if is_instance_valid(e) and e.has_method("take_damage"):
			e.take_damage(99999)
	if _elapsed > 120.0:
		print("BOSSTEST: TIMEOUT")
		quit(1)
	return false


func _on_cleared() -> void:
	print("BOSSTEST: boss level CLEARED")
	_done = true
	print("BOSSTEST: ALL PASSED")
	quit(0)
