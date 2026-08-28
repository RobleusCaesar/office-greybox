extends SceneTree
## Closet seated-still + guard-blood after shots. Headless.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	var packed: PackedScene = load("res://scenes/level.tscn")
	var level: Node = packed.instantiate()
	root.add_child(level)
	for _i in 20:
		await process_frame
	var mgr := level.get_node_or_null("FutureAssetSlots/IntroCloset/ClosetManager") as Node3D
	var intern := level.get_node_or_null("FutureAssetSlots/IntroCloset/ClosetIntern") as Node3D
	var player := level.get_node_or_null("Player") as Node3D
	var puddle := level.get_node_or_null("FutureAssetSlots/BreakRoom/GuardBloodPuddle") as Node3D
	var guard := level.get_node_or_null("FutureAssetSlots/BreakRoom/FallenSecurityGuard") as Node3D
	if mgr:
		var ma := _world_aabb(mgr)
		print("MANAGER pos=", mgr.position, " rot=", mgr.rotation_degrees, " scale=", mgr.scale, " aabb=", ma, " sit_top=", ma.position.y + ma.size.y)
	else:
		print("MANAGER_MISSING")
	if intern:
		var ia := _world_aabb(intern)
		print("INTERN pos=", intern.position, " rot=", intern.rotation_degrees, " scale=", intern.scale, " aabb=", ia, " sit_top=", ia.position.y + ia.size.y, " sole_y=", ia.position.y)
	else:
		print("INTERN_MISSING")
	if player:
		print("PLAYER pos=", player.position, " rot=", player.rotation_degrees, " sit=", player.get("sitting"), " eye=", player.get("SIT_EYE"), " scale=", player.scale)
	if puddle:
		var pa := _world_aabb(puddle)
		print("BLOOD pos=", puddle.position, " rot=", puddle.rotation_degrees, " scale=", puddle.scale, " aabb=", pa, " top=", pa.position.y + pa.size.y)
	else:
		print("BLOOD_MISSING")
	if guard:
		print("GUARD pos=", guard.position, " rot=", guard.rotation_degrees)
	var hud := level.get_node_or_null("Player/HUD") as CanvasLayer
	if hud:
		hud.visible = false
	# Intern vs manager seated height — both in frame from the west aisle.
	# Looking east: manager south/left, intern north/right of the vent.
	_aim(level, Vector3(-7.40, 1.12, 2.95), Vector3(-4.40, 0.55, 3.10), 70.0)
	for _j in 10:
		await process_frame
	_save("after-intern-vs-manager-height.png")
	# Intern north of the vent, mop south of the hole. Looking east at the wall.
	_aim(level, Vector3(-5.35, 1.12, 3.20), Vector3(-2.70, 0.42, 3.20), 68.0)
	for _j in 8:
		await process_frame
	_save("after-intern-vs-vent.png")
	# Shoes on the floor — side-on at sole height, not looking into her lap.
	if intern:
		var feet := intern.global_position
		_aim(level, Vector3(feet.x - 0.85, 0.22, feet.z - 0.55), Vector3(feet.x + 0.10, 0.02, feet.z + 0.05), 52.0)
	else:
		_aim(level, Vector3(-4.15, 0.22, 3.65), Vector3(-3.20, 0.02, 4.25), 52.0)
	for _j in 8:
		await process_frame
	_save("after-intern-shoes-floor.png")
	# Guard blood from Rob's playtest angle — stain flush, no gap under a slab.
	var halo := level.get_node_or_null("FutureAssetSlots/BreakRoom/ShotgunPickup")
	if halo:
		for c in halo.get_children():
			if c is Label3D:
				(c as Label3D).visible = false
	_aim(level, Vector3(2.45, 1.18, 4.55), Vector3(1.05, 0.04, 5.85), 58.0)
	for _j in 8:
		await process_frame
	_save("after-guard-blood-flush.png")
	# Extra: player sit POV at the manager still holds.
	_aim(level, Vector3(-6.20, 0.92, 4.20), Vector3(-6.20, 0.70, 1.70), 62.0)
	for _j in 8:
		await process_frame
	_save("after-closet-sit-player-pov.png")
	print("CAPTURE_OK closet sits after")
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


func _accum_aabb(n: Node, acc: Array) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh:
			var a: AABB = mi.global_transform * mi.mesh.get_aabb()
			if acc[0]:
				acc[1] = a
				acc[0] = false
			else:
				acc[1] = (acc[1] as AABB).merge(a)
	for c in n.get_children():
		_accum_aabb(c, acc)


func _world_aabb(n: Node3D) -> AABB:
	var acc := [true, AABB()]
	_accum_aabb(n, acc)
	if acc[0]:
		return AABB()
	return acc[1]
