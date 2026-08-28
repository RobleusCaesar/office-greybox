extends SceneTree
## Closet sit POV, break room, wall-seam closeup after the kit pass.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	var packed: PackedScene = load("res://scenes/level.tscn")
	var level: Node = packed.instantiate()
	root.add_child(level)
	for _i in 22:
		await process_frame
	var hud := level.get_node_or_null("Player/HUD") as CanvasLayer
	if hud:
		hud.visible = false
	var kit := level.get_node_or_null("OfficeKit")
	if kit and kit.has_meta("kit_counts"):
		print("KIT_COUNTS ", kit.get_meta("kit_counts"))
	else:
		print("KIT_MISSING")
	# Sit POV — player eye at the locked intro sit, facing the manager.
	_aim(level, Vector3(-6.20, 0.92, 4.20), Vector3(-6.20, 0.70, 1.70), 62.0)
	for _j in 10:
		await process_frame
	_save("kit-closet-sit-pov.png")
	# Break room from the north doorway, kitchen + carpet + fixtures.
	_aim(level, Vector3(3.50, 1.48, 6.05), Vector3(3.40, 0.55, 2.20), 64.0)
	for _j in 8:
		await process_frame
	_save("kit-break-room.png")
	# Wall-seam closeup — break-room west plaster, south of the vent, clear of the kitchenette.
	_aim(level, Vector3(1.35, 0.34, 1.85), Vector3(0.12, 0.06, 1.15), 42.0)
	for _j in 8:
		await process_frame
	_save("kit-wall-seam-closeup.png")
	print("CAPTURE_OK office kit stills")
	quit(0)


func _aim(level: Node, from: Vector3, to: Vector3, fov: float = 62.0) -> void:
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
	shot.fov = fov
	level.add_child(shot)
	shot.look_at_from_position(from, to, Vector3.UP)


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
	print("CAPTURE_OK ", name, " ", img.get_width(), "x", img.get_height())
