extends SceneTree
## Capture a screenshot of the main menu to verify CJK font rendering.

var _frames := 0
var _scene: Node = null


func _initialize() -> void:
	var packed := load("res://scenes/main_menu.tscn")
	_scene = packed.instantiate()
	get_root().add_child(_scene)


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == 30:
		var img := get_root().get_texture().get_image()
		img.save_png("user://menu_shot.png")
		print("SHOT: saved ", ProjectSettings.globalize_path("user://menu_shot.png"))
		quit(0)
	return false
