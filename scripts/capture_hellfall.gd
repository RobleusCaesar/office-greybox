extends SceneTree
## Capture title + key in-level stills for the HELLFALL ship.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	DirAccess.make_dir_recursive_absolute("/workspace/export/previews")
	await _shot_title()
	await _shot_level()
	print("CAPTURE_OK hellfall stills")
	quit(0)


func _save(name: String) -> void:
	var tex := root.get_viewport().get_texture()
	if tex == null:
		print("CAPTURE_FAIL no viewport for ", name)
		return
	var img := tex.get_image()
	if img == null:
		print("CAPTURE_FAIL empty image for ", name)
		return
	img.save_png("/opt/cursor/artifacts/%s" % name)
	img.save_png("/workspace/export/previews/%s" % name)
	print("CAPTURE_OK ", name, " ", img.get_width(), "x", img.get_height())


func _shot_title() -> void:
	var packed: PackedScene = load("res://scenes/title.tscn")
	var n: Node = packed.instantiate()
	root.add_child(n)
	for _i in 20:
		await process_frame
	_save("title-hellfall.png")
	n.queue_free()
	await process_frame


func _aim(level: Node, from: Vector3, to: Vector3) -> void:
	var player := level.get_node_or_null("Player") as Node3D
	if player and player.has_method("get_look_camera"):
		var pcam: Camera3D = player.get_look_camera()
		if pcam:
			pcam.current = false
	var old := level.get_node_or_null("CaptureCam")
	if old:
		old.free()
	var shot := Camera3D.new()
	shot.name = "CaptureCam"
	shot.current = true
	shot.fov = 62.0
	level.add_child(shot)
	shot.look_at_from_position(from, to, Vector3.UP)


func _shot_level() -> void:
	var packed: PackedScene = load("res://scenes/level.tscn")
	var level: Node = packed.instantiate()
	root.add_child(level)
	for _i in 12:
		await process_frame
	_aim(level, Vector3(36.2, 1.62, 11.50), Vector3(41.5, 1.55, 11.50))
	for _j in 10:
		await process_frame
	_save("window-reveal.png")
	_aim(level, Vector3(22.4, 1.55, 11.50), Vector3(26.0, 1.55, 11.50))
	for _j in 8:
		await process_frame
	_save("reception-aurum.png")
	_aim(level, Vector3(27.4, 1.45, 8.15), Vector3(32.0, 0.35, 11.50))
	for _j in 8:
		await process_frame
	_save("ceo-body.png")
	level.queue_free()
	await process_frame
