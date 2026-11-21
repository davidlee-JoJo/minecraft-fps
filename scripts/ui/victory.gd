extends Control
## Victory screen after beating the boss.

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.08, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "勝利！你征服了所有關卡"
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 10)
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(900, 0)
	title.position = Vector2(-450, -120)
	add_child(title)

	var score := Label.new()
	score.text = "最終分數：%d" % Game.score
	score.add_theme_font_size_override("font_size", 32)
	score.add_theme_color_override("font_color", Color.WHITE)
	score.set_anchors_preset(Control.PRESET_CENTER)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score.custom_minimum_size = Vector2(600, 0)
	score.position = Vector2(-300, -20)
	add_child(score)

	var btn := Button.new()
	btn.text = "回到主選單"
	btn.add_theme_font_size_override("font_size", 28)
	btn.custom_minimum_size = Vector2(240, 60)
	btn.set_anchors_preset(Control.PRESET_CENTER)
	btn.position = Vector2(-120, 60)
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	add_child(btn)
