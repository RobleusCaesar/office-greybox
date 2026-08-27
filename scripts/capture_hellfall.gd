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
	_aim(level, Vector3(19.15, 1.58, 11.55), Vector3(25.40, 1.35, 11.50))
	for _j in 8:
		await process_frame
	_save("ember-aurum.png")
	_aim(level, Vector3(19.55, 1.62, 11.55), Vector3(21.55, 1.85, 11.55))
	for _j in 8:
		await process_frame
	_save("ember-big.png")
	_aim(level, Vector3(22.35, 1.52, 11.50), Vector3(25.90, 1.45, 11.50))
	for _j in 8:
		await process_frame
	_save("reception-desk.png")
	_aim(level, Vector3(29.80, 1.42, 8.20), Vector3(33.40, 0.35, 11.45))
	for _j in 8:
		await process_frame
	_save("ceo-mid.png")
	_aim(level, Vector3(31.35, 1.28, 10.15), Vector3(32.10, 0.18, 11.55))
	for _j in 8:
		await process_frame
	_save("ceo-back-close.png")
	# Intro closet: three walls of shelves + boxes, looking west from the duct mouth.
	_aim(level, Vector3(-2.55, 1.52, 3.25), Vector3(-6.40, 1.15, 3.25))
	for _j in 10:
		await process_frame
	_save("intro-closet-aisle.png")
	# Corner that reads north + west + south runs.
	_aim(level, Vector3(-3.15, 1.48, 1.55), Vector3(-6.10, 1.20, 5.40))
	for _j in 8:
		await process_frame
	_save("intro-closet-shelves.png")
	# Kitchen west wall: sealed plaster, vent under the old window, cover off.
	_aim(level, Vector3(2.15, 1.28, 3.25), Vector3(0.05, 0.55, 3.20))
	for _j in 8:
		await process_frame
	_save("kitchen-west-vent.png")
	# Duct interior from the kitchen mouth.
	_aim(level, Vector3(0.42, 0.48, 3.20), Vector3(-2.40, 0.48, 3.20))
	for _j in 8:
		await process_frame
	_save("vent-duct-interior.png")
	level.queue_free()
	await process_frame
