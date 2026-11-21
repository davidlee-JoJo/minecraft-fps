extends CanvasLayer
class_name HUD

var _player: Node = null
var _crosshair: Control
var _health_label: Label
var _ammo_label: Label
var _score_label: Label
var _wave_label: Label
var _enemies_label: Label
var _level_label: Label
var _hit_marker: ColorRect
var _health_bar: ProgressBar
var _pending_level_name: String = ""
var _ready_done: bool = false


func setup(level_name: String, player: Node) -> void:
	_player = player
	_pending_level_name = level_name
	if _ready_done and is_instance_valid(_level_label):
		_level_label.text = level_name
		if player:
			if not player.health_changed.is_connected(set_health):
				player.health_changed.connect(set_health)
			if not player.ammo_changed.is_connected(set_ammo):
				player.ammo_changed.connect(set_ammo)
			set_health(player.health, player.max_health)
			set_ammo(player.mag, player.reserve)


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_crosshair = _make_crosshair()
	root.add_child(_crosshair)

	_hit_marker = ColorRect.new()
	_hit_marker.color = Color(1, 0.2, 0.2, 0.0)
	_hit_marker.set_anchors_preset(Control.PRESET_CENTER)
	_hit_marker.custom_minimum_size = Vector2(24, 24)
	_hit_marker.size = Vector2(24, 24)
	_hit_marker.position = Vector2(-12, -12)
	_hit_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_hit_marker)

	var font := ThemeDB.fallback_font

	_level_label = _make_label(font, 22, Color.WHITE)
	_level_label.position = Vector2(24, 16)
	root.add_child(_level_label)

	_wave_label = _make_label(font, 20, Color(1, 0.9, 0.4))
	_wave_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_wave_label.position = Vector2(-80, 20)
	_wave_label.custom_minimum_size = Vector2(160, 0)
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_wave_label)

	_enemies_label = _make_label(font, 18, Color(1, 0.6, 0.6))
	_enemies_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_enemies_label.position = Vector2(-80, 50)
	_enemies_label.custom_minimum_size = Vector2(160, 0)
	_enemies_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_enemies_label)

	_health_bar = ProgressBar.new()
	_health_bar.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_health_bar.position = Vector2(24, -60)
	_health_bar.custom_minimum_size = Vector2(240, 26)
	_health_bar.size = Vector2(240, 26)
	_health_bar.show_percentage = false
	_health_bar.max_value = 100
	_health_bar.value = 100
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.8, 0.15, 0.15)
	_health_bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	_health_bar.add_theme_stylebox_override("background", bg)
	root.add_child(_health_bar)

	_health_label = _make_label(font, 18, Color.WHITE)
	_health_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_health_label.position = Vector2(30, -58)
	root.add_child(_health_label)

	_ammo_label = _make_label(font, 28, Color.WHITE)
	_ammo_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_ammo_label.position = Vector2(-200, -64)
	_ammo_label.custom_minimum_size = Vector2(180, 0)
	_ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_ammo_label)

	_score_label = _make_label(font, 20, Color(0.6, 1, 0.6))
	_score_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_score_label.position = Vector2(-220, 16)
	_score_label.custom_minimum_size = Vector2(200, 0)
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_score_label)
	Game.score_changed.connect(func(s): _score_label.text = "分數 %d" % s)
	_score_label.text = "分數 %d" % Game.score

	if not _pending_level_name.is_empty():
		_level_label.text = _pending_level_name
	if _player:
		if not _player.health_changed.is_connected(set_health):
			_player.health_changed.connect(set_health)
		if not _player.ammo_changed.is_connected(set_ammo):
			_player.ammo_changed.connect(set_ammo)
		set_health(_player.health, _player.max_health)
		set_ammo(_player.mag, _player.reserve)
	_ready_done = true


func _make_crosshair() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_CENTER)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 4:
		var r := ColorRect.new()
		r.color = Color(1, 1, 1, 0.85)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.size = Vector2(2, 8) if i < 2 else Vector2(8, 2)
		r.position = [Vector2(-1, -14), Vector2(-1, 6), Vector2(-14, -1), Vector2(6, -1)][i]
		c.add_child(r)
	return c


func _make_label(font: Font, size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func set_health(cur: int, mx: int) -> void:
	if not is_instance_valid(_health_bar):
		return
	_health_bar.max_value = mx
	_health_bar.value = cur
	_health_label.text = "HP %d/%d" % [cur, mx]


func set_ammo(mag: int, reserve: int) -> void:
	if not is_instance_valid(_ammo_label):
		return
	_ammo_label.text = "%d / %d" % [mag, reserve]
	_ammo_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4) if mag == 0 else Color.WHITE)


func show_wave(wave: int, total: int) -> void:
	if not is_instance_valid(_wave_label):
		return
	_wave_label.text = "波次 %d / %d" % [wave, total]


func set_enemies_left(n: int) -> void:
	if not is_instance_valid(_enemies_label):
		return
	_enemies_label.text = "剩餘敵人 %d" % n


func flash_hit(killed: bool) -> void:
	if not is_instance_valid(_hit_marker):
		return
	_hit_marker.color = Color(1, 0.1, 0.1, 0.9) if killed else Color(1, 1, 1, 0.6)
	var tween := create_tween()
	tween.tween_property(_hit_marker, "color:a", 0.0, 0.25)
