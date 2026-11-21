extends SceneTree
## Headless smoke test: loads menu + each level, runs a few frames, reports errors.

var _scenes := [
	"res://scenes/main_menu.tscn",
	"res://scenes/level_01.tscn",
	"res://scenes/level_02.tscn",
	"res://scenes/level_03.tscn",
	"res://scenes/level_04.tscn",
	"res://scenes/level_05.tscn",
	"res://scenes/boss_level.tscn",
	"res://scenes/victory.tscn",
]

var _index := 0
var _frames := 0


func _initialize() -> void:
	print("SMOKE: begin")
	_load_next()


func _load_next() -> void:
	if _index >= _scenes.size():
		print("SMOKE: ALL PASSED")
		quit(0)
		return
	var path: String = _scenes[_index]
	print("SMOKE: loading ", path)
	var packed := load(path)
	if packed == null:
		print("SMOKE FAIL: cannot load ", path)
		quit(1)
		return
	var inst = packed.instantiate()
	get_root().add_child(inst)
	_frames = 0


func _process(_delta: float) -> bool:
	if _index >= _scenes.size():
		return false
	_frames += 1
	if _frames >= 30:
		var inst = get_root().get_child(get_root().get_child_count() - 1)
		inst.queue_free()
		_index += 1
		_load_next()
	return false
