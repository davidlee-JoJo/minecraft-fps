extends Node
## Global game state: level progression, score, settings.
## Persists across scenes. Linear unlock: level N unlocks after N-1 cleared.

signal score_changed(new_score: int)
signal level_unlocked(index: int)

const LEVEL_NAMES := [
	"草原 Plains",
	"沙漠 Desert",
	"雪地 Snowfield",
	"地獄 Nether",
	"終界 The End",
]

var score: int = 0
var highest_unlocked: int = 0
var current_level: int = 0
var unlocked_levels: Array[int] = [0]


func _ready() -> void:
	load_progress()


func reset_run() -> void:
	score = 0
	current_level = 0
	score_changed.emit(score)


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func complete_level(index: int) -> void:
	var next := index + 1
	if next <= LEVEL_NAMES.size() and not unlocked_levels.has(next):
		unlocked_levels.append(next)
		highest_unlocked = max(highest_unlocked, next)
		level_unlocked.emit(next)
	save_progress()


func is_unlocked(index: int) -> bool:
	return unlocked_levels.has(index)


func get_level_name(index: int) -> String:
	if index >= 0 and index < LEVEL_NAMES.size():
		return LEVEL_NAMES[index]
	return "魔王競技場"


func get_spawn_root() -> Node:
	var cs := get_tree().current_scene
	if cs:
		return cs
	return get_tree().root


func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked", unlocked_levels)
	cfg.set_value("progress", "high_score", score)
	cfg.save("user://save.cfg")


func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		var u = cfg.get_value("progress", "unlocked", [0])
		unlocked_levels.clear()
		for v in u:
			unlocked_levels.append(int(v))
		if unlocked_levels.is_empty():
			unlocked_levels = [0]
		highest_unlocked = unlocked_levels.max()
