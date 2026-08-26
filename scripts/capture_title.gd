extends SceneTree
## Headless / windowed title screenshot for the PR.


func _init() -> void:
	call_deferred("_go")


func _go() -> void:
	var packed: PackedScene = load("res://scenes/title.tscn")
	if packed == null:
		push_error("capture: title.tscn missing")
		quit(1)
		return
	var title: Node = packed.instantiate()
	root.add_child(title)
	for _i in 24:
		await process_frame
	var tex := root.get_viewport().get_texture()
	if tex == null:
		push_error("capture: no viewport texture")
		quit(1)
		return
	var img := tex.get_image()
	DirAccess.make_dir_recursive_absolute("res://export/previews")
	var dest := "res://export/previews/title-menu-shot.png"
	var err := img.save_png(dest)
	if err != OK:
		# Fallback to absolute workspace path if res:// export is ignored.
		img.save_png("/opt/cursor/artifacts/title_menu.png")
		print("CAPTURE_OK /opt/cursor/artifacts/title_menu.png")
	else:
		img.save_png("/opt/cursor/artifacts/title_menu.png")
		print("CAPTURE_OK ", dest)
	quit(0)
