extends SceneTree
## Windowed/Xvfb title screenshot. Avoids await so it cannot stall.

var _frames: int = 0
var _title: Node


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/title.tscn")
	if packed == null:
		push_error("capture: title.tscn missing")
		quit(1)
		return
	_title = packed.instantiate()
	root.add_child(_title)


func _process(_dt: float) -> bool:
	_frames += 1
	if _frames < 18:
		return false
	var vp := root.get_viewport()
	if vp == null:
		push_error("capture: no viewport")
		quit(1)
		return true
	var tex := vp.get_texture()
	if tex == null:
		push_error("capture: no viewport texture")
		quit(1)
		return true
	var img := tex.get_image()
	if img == null:
		push_error("capture: empty image")
		quit(1)
		return true
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	DirAccess.make_dir_recursive_absolute("/workspace/export/previews")
	img.save_png("/opt/cursor/artifacts/title_hellfall.png")
	img.save_png("/workspace/export/previews/title-hellfall.png")
	print("CAPTURE_OK title_menu.png %dx%d" % [img.get_width(), img.get_height()])
	quit(0)
	return true
