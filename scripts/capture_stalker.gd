extends SceneTree
## Cubicle-spawn still of the Meshy Abyssal Stalker (Idle_8). Compatibility only.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var level: Node = (load("res://scenes/level.tscn") as PackedScene).instantiate()
	root.add_child(level)
	for _i in 10:
		await process_frame
	var player := level.get_node_or_null("Player") as Node3D
	if player and player.has_method("get_look_camera"):
		var pcam: Camera3D = player.get_look_camera()
		if pcam:
			pcam.current = false
	var shot := Camera3D.new()
	shot.name = "StalkerCaptureCam"
	shot.current = true
	shot.fov = 52.0
	level.add_child(shot)
	# Just inside the cubicle, looking at the SE-corner ambush (DemonSpot_01).
	shot.look_at_from_position(Vector3(9.25, 1.55, 10.05), Vector3(10.20, 0.95, 8.30), Vector3.UP)
	var d1 := level.get_node_or_null("Demon_01")
	if d1 and d1.has_method("imported_clip_names"):
		print("STALKER_CLIPS ", ", ".join(d1.imported_clip_names()))
	elif d1 == null:
		print("STALKER_CLIPS (no Demon_01)")
	else:
		print("STALKER_CLIPS (empty — GLB not instanced)")
	for _j in 12:
		await process_frame
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	var tex := root.get_viewport().get_texture()
	var img: Image = tex.get_image() if tex else null
	if img == null:
		print("CAPTURE_FAIL viewport image is null (need a real display, not dummy renderer)")
		quit(1)
		return
	img.save_png("/opt/cursor/artifacts/stalker_cubicle_spawn.png")
	print("CAPTURE_OK stalker_cubicle_spawn.png")
	quit(0)
