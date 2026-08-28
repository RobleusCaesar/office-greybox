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
	# Guard leaned in the NW doorway × crawl-hole corner.
	_aim(level, Vector3(2.40, 1.35, 4.20), Vector3(0.45, 0.28, 5.85))
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
	# Playtest pass — unique names so earlier Meshy stills stay.
	_aim(level, Vector3(10.48, 1.38, 10.25), Vector3(10.20, 0.55, 8.35))
	for _j in 8:
		await process_frame
	_save("playtest-stalker-chase-path.png")
	_aim(level, Vector3(9.40, 1.42, 10.15), Vector3(8.10, 0.55, 8.40))
	for _j in 8:
		await process_frame
	_save("playtest-alcove-cubicle.png")
	_aim(level, Vector3(9.55, 1.42, 13.55), Vector3(8.20, 0.45, 15.05))
	for _j in 8:
		await process_frame
	_save("playtest-alcove-copy.png")
	_aim(level, Vector3(3.50, 1.48, 11.40), Vector3(2.10, 1.05, 8.90))
	for _j in 8:
		await process_frame
	_save("playtest-hall-no-bath-door.png")
	_aim(level, Vector3(3.15, 1.42, 9.00), Vector3(1.70, 0.55, 8.45))
	for _j in 8:
		await process_frame
	_save("playtest-bathroom-fallen-door.png")
	_aim(level, Vector3(12.20, 1.52, 11.70), Vector3(16.80, 1.55, 13.20))
	for _j in 8:
		await process_frame
	_save("playtest-left-hall-art.png")
	_aim(level, Vector3(21.80, 1.55, 11.50), Vector3(25.82, 1.70, 11.50))
	for _j in 8:
		await process_frame
	_save("playtest-logo-desk.png")
	_aim(level, Vector3(1.90, 1.20, 3.25), Vector3(0.00, 0.48, 3.20))
	for _j in 8:
		await process_frame
	_save("playtest-vent-kitchen.png")
	_aim(level, Vector3(-5.20, 1.20, 3.25), Vector3(-2.66, 0.48, 3.20))
	for _j in 8:
		await process_frame
	_save("playtest-vent-closet.png")
	_aim(level, Vector3(6.80, 1.50, 12.00), Vector3(16.50, 1.20, 12.00))
	for _j in 8:
		await process_frame
	_save("playtest-l-hall-flat.png")
	_aim(level, Vector3(8.80, 1.15, 12.00), Vector3(9.40, 0.02, 12.40))
	for _j in 8:
		await process_frame
	_save("playtest-carpet-vs-wall.png")
	if level.get_node_or_null("FutureAssetSlots/IntroCloset/MopAndBucket"):
		_aim(level, Vector3(-4.40, 1.20, 3.25), Vector3(-2.90, 0.40, 2.40))
		for _j in 8:
			await process_frame
		_save("mop-and-bucket.png")
	# Playtest fix 2 stills.
	_aim(level, Vector3(3.40, 1.55, 9.00), Vector3(1.70, 0.40, 9.00))
	for _j in 8:
		await process_frame
	_save("fix2-bath-threshold.png")
	_aim(level, Vector3(3.50, 1.50, 7.80), Vector3(2.10, 1.10, 9.00))
	for _j in 8:
		await process_frame
	_save("fix2-hall-flush.png")
	_aim(level, Vector3(0.15, 1.48, 9.40), Vector3(0.15, 1.55, 6.72))
	for _j in 8:
		await process_frame
	_save("fix2-vanity-mirror.png")
	_aim(level, Vector3(0.50, 1.30, 10.40), Vector3(0.50, 0.80, 12.85))
	for _j in 8:
		await process_frame
	_save("fix2-urinals-back-wall.png")
	_aim(level, Vector3(11.20, 1.52, 12.00), Vector3(16.80, 1.25, 12.00))
	for _j in 8:
		await process_frame
	_save("fix2-ember-approach.png")
	_aim(level, Vector3(22.60, 1.48, 10.20), Vector3(24.70, 0.55, 11.50))
	for _j in 8:
		await process_frame
	_save("fix2-desk-flipped.png")
	_aim(level, Vector3(31.20, 1.20, 10.20), Vector3(32.10, 0.20, 11.50))
	for _j in 8:
		await process_frame
	_save("fix2-ceo-facedown.png")
	_aim(level, Vector3(2.05, 1.28, 4.55), Vector3(0.50, 0.12, 5.70))
	for _j in 8:
		await process_frame
	_save("fix2-guard-corner.png")
	_aim(level, Vector3(3.50, 1.45, 6.05), Vector3(3.50, 0.40, 3.70))
	for _j in 8:
		await process_frame
	_save("fix2-table-no-chair-blocks.png")
	_aim(level, Vector3(3.20, 1.48, 8.50), Vector3(5.00, 1.05, 8.50))
	for _j in 8:
		await process_frame
	_save("fix2-elevator.png")
	# Closet spawn: seated, looking at the manager. Not the vent. Unarmed.
	_aim(level, Vector3(-6.20, 0.92, 4.20), Vector3(-6.20, 0.72, 1.70))
	for _j in 10:
		await process_frame
	_save("closet-sit-player-pov.png")
	_aim(level, Vector3(-4.10, 1.15, 3.55), Vector3(-6.10, 0.55, 1.70))
	for _j in 8:
		await process_frame
	_save("closet-sit-manager.png")
	_aim(level, Vector3(-5.40, 1.05, 3.10), Vector3(-3.40, 0.55, 1.20))
	for _j in 8:
		await process_frame
	_save("closet-sit-intern.png")
	_aim(level, Vector3(-5.10, 1.35, 4.55), Vector3(-5.20, 0.55, 1.80))
	for _j in 8:
		await process_frame
	_save("closet-sit-wide.png")
	# Shotgun on the break-room floor next to the guard.
	_aim(level, Vector3(2.55, 1.20, 4.35), Vector3(1.55, 0.12, 5.30))
	for _j in 8:
		await process_frame
	_save("fix5-shotgun-by-guard.png")
	# Founder pass 3 — mop yaw, guard+puddle on the wall, hall opening, new door, drip, couches.
	_aim(level, Vector3(-4.40, 1.20, 3.25), Vector3(-2.90, 0.40, 2.40))
	for _j in 8:
		await process_frame
	_save("fix3-mop-yaw-flip.png")
	_aim(level, Vector3(2.15, 1.28, 4.40), Vector3(0.55, 0.18, 5.85))
	for _j in 8:
		await process_frame
	_save("fix3-guard-wall-puddle.png")
	_aim(level, Vector3(3.50, 1.50, 11.20), Vector3(2.00, 1.05, 9.00))
	for _j in 8:
		await process_frame
	_save("fix3-hall-bath-opening.png")
	_aim(level, Vector3(1.35, 1.20, 9.10), Vector3(0.70, 0.12, 7.55))
	for _j in 8:
		await process_frame
	_save("fix3-broken-door-south-jamb.png")
	_aim(level, Vector3(0.20, 1.35, 10.20), Vector3(1.90, 1.10, 11.15))
	for _j in 8:
		await process_frame
	_save("fix3-bathroom-drip-wall.png")
	_aim(level, Vector3(31.40, 1.35, 11.50), Vector3(27.40, 0.45, 11.50))
	for _j in 8:
		await process_frame
	_save("fix3-ceo-couches.png")
	# From inside the CEO office, window-side, so leather/wood must read (not black).
	_aim(level, Vector3(30.60, 1.42, 11.50), Vector3(27.48, 0.42, 11.50))
	for _j in 10:
		await process_frame
	_save("fix4-ceo-couches-textured.png")
	_aim(level, Vector3(29.20, 1.28, 10.15), Vector3(27.55, 0.38, 11.35))
	for _j in 8:
		await process_frame
	_save("fix4-ceo-couches-doorway.png")
	var hud3 := level.get_node_or_null("Player/HUD") as CanvasLayer
	if hud3:
		hud3.visible = false
	var player2 := level.get_node_or_null("Player") as Node3D
	if player2 and player2.has_method("get_look_camera"):
		var cap := level.get_node_or_null("CaptureCam")
		if cap and cap is Camera3D:
			(cap as Camera3D).current = false
		var pcam3: Camera3D = player2.get_look_camera()
		if pcam3:
			pcam3.current = true
	for _j in 10:
		await process_frame
	_save("fix2-shotgun-hands.png")
	level.queue_free()
	await process_frame
