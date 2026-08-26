extends SceneTree
## Cubicle-spawn still of the Meshy Abyssal Stalker (Idle_8). Compatibility only.

var _frames: int = 0
var _level: Node


func _initialize() -> void:
	_level = (load("res://scenes/level.tscn") as PackedScene).instantiate()
	root.add_child(_level)
	var player := _level.get_node_or_null("Player") as Node3D
	if player and player.has_method("get_look_camera"):
		var pcam: Camera3D = player.get_look_camera()
		if pcam:
			pcam.current = false
	var shot := Camera3D.new()
	shot.name = "StalkerCaptureCam"
	shot.current = true
	shot.fov = 52.0
	_level.add_child(shot)
	# Hall side of the cubicle opening, looking in at DemonSpot_01.
	shot.look_at_from_position(Vector3(9.25, 1.55, 12.40), Vector3(9.25, 0.95, 10.20), Vector3.UP)


func _process(_dt: float) -> bool:
	_frames += 1
	if _frames == 2:
		var d1 := _level.get_node_or_null("Demon_01")
		if d1 and d1.has_method("imported_clip_names"):
			print("STALKER_CLIPS ", ", ".join(d1.imported_clip_names()))
		elif d1 == null:
			print("STALKER_CLIPS (no Demon_01)")
	if _frames < 22:
		return false
	var img := root.get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	img.save_png("/opt/cursor/artifacts/stalker_cubicle_spawn.png")
	print("CAPTURE_OK stalker_cubicle_spawn.png")
	quit(0)
	return true
