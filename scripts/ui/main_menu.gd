extends Control
## Main menu: title, level list (linear unlock), start, quit.

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.11, 0.13)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "MineCraft FPS"
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.5, 0.9, 0.4))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 10)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(800, 0)
	title.position = Vector2(-400, 70)
	add_child(title)

	var sub := Label.new()
	sub.text = "方塊世界的生存射擊"
	sub.add_theme_font_size_override("font_size", 24)
	sub.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.custom_minimum_size = Vector2(800, 0)
	sub.position = Vector2(-400, 160)
	add_child(sub)

	var list := VBoxContainer.new()
	list.set_anchors_preset(Control.PRESET_CENTER)
	list.position = Vector2(-200, -120)
	list.custom_minimum_size = Vector2(400, 0)
	list.add_theme_constant_override("separation", 12)
	add_child(list)

	for i in Game.LEVEL_NAMES.size():
		var unlocked := Game.is_unlocked(i)
		var btn := Button.new()
		btn.text = "%d. %s" % [i + 1, Game.LEVEL_NAMES[i]] if unlocked else "%d. ??? (未解鎖)" % (i + 1)
		btn.custom_minimum_size = Vector2(400, 52)
		btn.add_theme_font_size_override("font_size", 24)
		btn.disabled = not unlocked
		btn.pressed.connect(_start_level.bind(i))
		list.add_child(btn)

	var boss_unlocked := Game.is_unlocked(5)
	var boss_btn := Button.new()
	boss_btn.text = "★ 魔王競技場" if boss_unlocked else "★ 魔王競技場 (未解鎖)"
	boss_btn.custom_minimum_size = Vector2(400, 52)
	boss_btn.add_theme_font_size_override("font_size", 24)
	boss_btn.disabled = not boss_unlocked
	boss_btn.pressed.connect(_start_level.bind(5))
	list.add_child(boss_btn)

	var hint := Label.new()
	hint.text = "WASD 移動 · 滑鼠瞄準 · 左鍵射擊 · R 換彈 · Shift 衝刺 · 空白鍵跳躍"
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.custom_minimum_size = Vector2(900, 0)
	hint.position = Vector2(-450, -50)
	add_child(hint)


func _start_level(index: int) -> void:
	if index == 5:
		get_tree().change_scene_to_file("res://scenes/boss_level.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/level_%02d.tscn" % (index + 1))
