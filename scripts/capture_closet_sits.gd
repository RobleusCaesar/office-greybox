extends SceneTree
## Closet seated-still proof shots. Headless.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	var packed: PackedScene = load("res://scenes/level.tscn")
	var level: Node = packed.instantiate()
	root.add_child(level)
	for _i in 16:
		await process_frame
	var mgr := level.get_node_or_null("FutureAssetSlots/IntroCloset/ClosetManager") as Node3D
	var intern := level.get_node_or_null("FutureAssetSlots/IntroCloset/ClosetIntern") as Node3D
	var player := level.get_node_or_null("Player") as Node3D
	if mgr:
		print("MANAGER pos=", mgr.position, " rot=", mgr.rotation_degrees, " scale=", mgr.scale)
	else:
		print("MANAGER_MISSING")
	if intern:
		print("INTERN pos=", intern.position, " rot=", intern.rotation_degrees, " scale=", intern.scale)
	else:
		print("INTERN_MISSING")
	if player:
		print("PLAYER pos=", player.position, " rot=", player.rotation_degrees, " sit=", player.get("sitting"), " eye=", player.get("SIT_EYE"))
	_aim(level, Vector3(-6.20, 0.92, 4.20), Vector3(-6.20, 0.70, 1.70))
	for _j in 12:
		await process_frame
	_save("closet-sit-player-pov.png")
	_aim(level, Vector3(-4.00, 1.20, 3.60), Vector3(-6.10, 0.50, 1.65))
	for _j in 8:
		await process_frame
	_save("closet-sit-manager.png")
	_aim(level, Vector3(-5.50, 1.10, 3.15), Vector3(-3.40, 0.55, 1.15))
	for _j in 8:
		await process_frame
	_save("closet-sit-intern.png")
	_aim(level, Vector3(-5.00, 1.45, 4.70), Vector3(-5.10, 0.50, 1.70))
	for _j in 8:
		await process_frame
	_save("closet-sit-wide.png")
	_aim(level, Vector3(-4.80, 0.95, 3.20), Vector3(-2.66, 0.40, 3.20))
	for _j in 8:
		await process_frame
	_save("closet-sit-vent-clear.png")
	print("CAPTURE_OK closet sits")
	quit(0)


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
