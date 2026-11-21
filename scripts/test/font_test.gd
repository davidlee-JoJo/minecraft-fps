extends SceneTree

func _initialize() -> void:
	var f: FontFile = load("res://assets/fonts/kaiu.ttf")
	if f == null:
		print("FONTTEST: load failed")
		quit(1)
		return
	var tests := ["草原", "魔王競技場", "分數", "開始", "ABC"]
	for t in tests:
		var ok := true
		for ch in t:
			var cp: int = ch.unicode_at(0)
			if not f.has_char(cp):
				ok = false
				print("  MISSING char U+%04X (%s)" % [cp, ch])
		print("FONTTEST: '%s' -> %s" % [t, "OK" if ok else "MISSING"])
	# render a size measurement to confirm glyphs have advance
	var sz := f.get_string_size("草原魔王競技場", HORIZONTAL_ALIGNMENT_LEFT, -1, 32)
	print("FONTTEST: measured width = ", sz.x, " height = ", sz.y)
	print("FONTTEST: DONE")
	quit(0)
