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
	var hud := level.get_node_or_null("Player/HUD") as CanvasLayer
	if hud:
		hud.visible = false
	# Closet looking EAST — vent is a hole in IntroClosetEast, no black box in the room.
	_aim(level, Vector3(-5.40, 1.35, 3.25), Vector3(-2.66, 0.48, 3.20))
	for _j in 10:
		await process_frame
	_save("intro_closet_east_vent.png")
	# Closet aisle: carpet + light + three walls of shelves.
	_aim(level, Vector3(-4.40, 1.48, 3.25), Vector3(-8.80, 1.05, 3.25))
	for _j in 8:
		await process_frame
	_save("intro_closet_aisle.png")
	# Shelf boxes so FRAGILE / COPY PAPER read at aisle distance.
	_aim(level, Vector3(-6.40, 1.28, 2.20), Vector3(-7.40, 1.05, 0.55))
	for _j in 8:
		await process_frame
	_save("intro_closet_shelf_boxes.png")
	# Floor carton so FRAGILE / tape faces read as dedicated albedos.
	_aim(level, Vector3(-7.81, 0.58, 1.85), Vector3(-8.51, 0.32, 1.05))
	for _j in 8:
		await process_frame
	_save("intro_closet_fragile_carton.png")
	# Kitchen west wall: hole in BreakRoomWest, duct does not stick into the kitchen.
	_aim(level, Vector3(1.85, 1.22, 3.25), Vector3(0.00, 0.48, 3.20))
	for _j in 8:
		await process_frame
	_save("kitchen_west_vent.png")
	# Duct interior from the kitchen mouth — gap only.
	_aim(level, Vector3(0.38, 0.46, 3.20), Vector3(-2.60, 0.46, 3.20))
	for _j in 8:
		await process_frame
	_save("vent_duct_interior.png")
	# Shotgun in first-person hands at spawn.
	var hud2 := level.get_node_or_null("Player/HUD") as CanvasLayer
	if hud2:
		hud2.visible = false
	var pcam_on := false
	var player := level.get_node_or_null("Player") as Node3D
	if player and player.has_method("get_look_camera"):
		var pcam: Camera3D = player.get_look_camera()
		if pcam:
			var old_cap := level.get_node_or_null("CaptureCam")
			if old_cap and old_cap is Camera3D:
				(old_cap as Camera3D).current = false
			pcam.current = true
			pcam_on = true
	for _j in 10:
		await process_frame
	_save("shotgun-in-hands.png")
	if pcam_on and player and player.has_method("get_look_camera"):
		var pcam2: Camera3D = player.get_look_camera()
		if pcam2:
			pcam2.current = false
	# Guard in the NE break-room corner (EXIT), opposite the west vent.
	_aim(level, Vector3(3.70, 1.35, 4.40), Vector3(5.85, 0.25, 5.72))
	for _j in 8:
		await process_frame
	_save("guard-breakroom-corner.png")
	# Fridge + lunch table from the north doorway.
	_aim(level, Vector3(3.50, 1.45, 6.10), Vector3(4.80, 0.55, 2.40))
	for _j in 8:
		await process_frame
	_save("fridge-lunch-table.png")
	# Bathroom vanity + toilets (look south-west so sinks and a stall bowl share the frame).
	_aim(level, Vector3(-1.10, 1.35, 10.40), Vector3(-2.40, 0.55, 7.40))
	for _j in 8:
		await process_frame
	_save("bathroom-vanity-toilets.png")
	# Stall toilets from the aisle.
	_aim(level, Vector3(-3.10, 1.20, 9.50), Vector3(-5.35, 0.40, 9.10))
	for _j in 8:
		await process_frame
	_save("bathroom-stall-toilets.png")
	# Locked supply door.
	_aim(level, Vector3(3.15, 1.45, 8.50), Vector3(5.00, 1.05, 8.50))
	for _j in 8:
		await process_frame
	_save("locked-door-supply.png")
	if level.get_node_or_null("FutureAssetSlots/IntroCloset/MopAndBucket"):
		_aim(level, Vector3(-4.40, 1.20, 3.25), Vector3(-2.90, 0.40, 2.40))
		for _j in 8:
			await process_frame
		_save("mop-and-bucket.png")
	level.queue_free()
	await process_frame
