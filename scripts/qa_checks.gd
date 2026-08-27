extends SceneTree
## Headless QA for the live loop.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var errors: PackedStringArray = PackedStringArray()
	var main_scene := str(ProjectSettings.get_setting("application/run/main_scene"))
	if main_scene != "res://scenes/title.tscn":
		errors.append("main_scene is %s, expected title.tscn" % main_scene)
	var renderer := str(ProjectSettings.get_setting("rendering/renderer/rendering_method"))
	if renderer != "gl_compatibility":
		errors.append("renderer is %s, expected gl_compatibility" % renderer)
	if not InputMap.has_action("crouch"):
		errors.append("missing crouch action")
	if not InputMap.has_action("crawl"):
		errors.append("missing crawl action")
	elif not _action_has_key("crawl", KEY_C):
		errors.append("C must toggle crawl")
	if _action_has_key("crouch", KEY_C) or _action_has_key("reload", KEY_C) or _action_has_key("interact", KEY_C):
		errors.append("C stole an existing action")
	if InputMap.has_action("crouch") and not _action_has_key("crouch", KEY_SPACE):
		errors.append("Space must remain crouch")
	if InputMap.has_action("jump"):
		errors.append("jump action still present")
	if not InputMap.has_action("interact"):
		errors.append("missing interact action")
	var app_name := str(ProjectSettings.get_setting("application/config/name"))
	if app_name != "HELLFALL":
		errors.append("project name is %s, expected HELLFALL" % app_name)
	var stretch_mode := str(ProjectSettings.get_setting("display/window/stretch/mode"))
	if stretch_mode != "canvas_items":
		errors.append("stretch mode is %s" % stretch_mode)
	var stretch_aspect := str(ProjectSettings.get_setting("display/window/stretch/aspect"))
	if stretch_aspect != "expand":
		errors.append("stretch aspect is %s, expected expand" % stretch_aspect)
	if not FileAccess.file_exists("res://textures/hero/title-17th-street.png"):
		errors.append("title-17th-street.png missing")
	if not FileAccess.file_exists("res://textures/hero/denver-fire-capitol-demon.png"):
		errors.append("denver-fire-capitol-demon.png missing")
	if not FileAccess.file_exists("res://textures/hero/aurum-logo.png"):
		errors.append("aurum-logo.png missing")
	if not FileAccess.file_exists("res://textures/hero/shotgun-walnut-steel.png"):
		errors.append("shotgun-walnut-steel.png missing")
	if not FileAccess.file_exists("res://audio/haunt_bed.wav"):
		errors.append("haunt_bed.wav missing")
	if not FileAccess.file_exists("res://audio/shotgun_fire.wav"):
		errors.append("shotgun_fire.wav missing")
	for wav_name in ["shotgun_blast.wav", "shotgun_cocking.wav", "shotgun_reloading.wav"]:
		var wav_path := "res://audio/%s" % wav_name
		if not FileAccess.file_exists(wav_path):
			errors.append("%s missing" % wav_name)
		if not FileAccess.file_exists(wav_path + ".import"):
			errors.append("%s.import missing — web export will skip this wav" % wav_name)
	for pack_name in [
		"deamon_attack.mp3", "deamon_attack2.wav", "deamon_growl.wav",
		"deamon_growl_distant.mp3", "monster_screech_distant.wav",
	]:
		var pack_path := "res://audio/%s" % pack_name
		if not FileAccess.file_exists(pack_path + ".import"):
			errors.append("%s.import missing — web export will skip this audio" % pack_name)
	if not FileAccess.file_exists("res://models/reception_desk.glb.import"):
		errors.append("reception_desk.glb.import missing — web export will skip this glb")
	if not FileAccess.file_exists("res://models/blood_pool.glb.import"):
		errors.append("blood_pool.glb.import missing — web export will skip this glb")
	for glb_name in [
		"shotgun.glb", "ceo_dead2.glb", "fallen_security_guard.glb",
		"refrigerator_open.glb", "kitchen_lunch_table.glb",
		"bathroom_vanity.glb", "toiletbowl.glb", "closed_door.glb",
		"closed_elevator.glb", "mop_and_bucket.glb",
		"broken_door.glb", "CEO_couch_coffee_table.glb",
		"blood_decal_1.glb", "blood_decal_2.glb",
	]:
		if not FileAccess.file_exists("res://models/%s" % glb_name):
			errors.append("%s missing" % glb_name)
		if not FileAccess.file_exists("res://models/%s.import" % glb_name):
			errors.append("%s.import missing — web export will skip this glb" % glb_name)
	if not FileAccess.file_exists("res://textures/gen/blood_smear.png"):
		errors.append("blood_smear.png missing")
	if not FileAccess.file_exists("res://textures/hero/blood-spray-hq.png"):
		errors.append("blood-spray-hq.png missing")
	var title_src := FileAccess.get_file_as_string("res://scripts/title.gd")
	if title_src.contains("denver-fire-vista"):
		errors.append("title must not use denver-fire-vista")
	if title_src.contains("backdrop.scale") or title_src.contains("func _process"):
		errors.append("title Ken Burns / _process scale must be gone")
	var title_scn := FileAccess.get_file_as_string("res://scenes/title.tscn")
	if not title_scn.contains("title-17th-street.png"):
		errors.append("title.tscn must use title-17th-street.png")
	if not title_scn.contains("stretch_mode = 6"):
		errors.append("title backdrop must be COVER (6)")
	if not title_scn.contains("HELLFALL"):
		errors.append("title wordmark must be HELLFALL")
	if not title_scn.contains("Chapter 1: The Fall"):
		errors.append("title tag missing")
	var title_ps: PackedScene = load("res://scenes/title.tscn")
	if title_ps == null:
		errors.append("could not load title.tscn")
	else:
		var title_n: Node = title_ps.instantiate()
		root.add_child(title_n)
		await process_frame
		if title_n.get_node_or_null("%Backdrop") == null:
			errors.append("title backdrop missing")
		if title_n.get_node_or_null("%Play") == null or title_n.get_node_or_null("%Quit") == null:
			errors.append("title Play/Quit unique names missing")
		title_n.queue_free()
		await process_frame

	var packed: PackedScene = load("res://scenes/level.tscn")
	if packed == null:
		errors.append("could not load level.tscn")
		_finish(errors)
		return
	var level: Node = packed.instantiate()
	root.add_child(level)
	for _i in 8:
		await process_frame

	if level.get_node_or_null("ExteriorDiorama") == null:
		errors.append("ExteriorDiorama missing")
	if level.get_node_or_null("Demon_02") != null:
		errors.append("second demon must not exist")
	var ember := level.get_node_or_null("Ember_01") as Node3D
	if ember == null:
		errors.append("Ember_01 missing at DemonSpot_Reception")
	else:
		var ep := ember.global_position
		if absf(ep.x - 21.55) > 0.40 or absf(ep.z - 11.55) > 0.40:
			errors.append("Ember_01 at %s, expected ~21.55, 0, 11.55" % ep)
		var yaw := ember.rotation_degrees.y
		if absf(yaw + 90.0) > 8.0 and absf(absf(yaw) - 270.0) > 8.0:
			errors.append("Ember_01 yaw %s, expected -90" % yaw)
		if absf(ember.scale.x - 1.30) > 0.05:
			errors.append("Ember_01 scale %s, expected 1.30" % ember.scale)
		if ember.get_node_or_null("EmberDemon") == null and ember.get_node_or_null("EmberPlaceholder") == null:
			errors.append("Ember_01 has no mesh")
	if level.get_node_or_null("DemonSpots/DemonSpot_Reception") == null:
		errors.append("DemonSpot_Reception missing")
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/BreakRoomTV") == null:
		errors.append("break room TV missing")
	if level.get_node_or_null("FutureAssetSlots/IntroCloset") == null:
		errors.append("IntroCloset missing")
	var ic_floor := level.get_node_or_null("Architecture/Floors/IntroClosetFloor") as CSGBox3D
	if ic_floor == null:
		errors.append("IntroCloset floor missing")
	else:
		if ic_floor.size.x < 6.0 or ic_floor.size.z < 6.0:
			errors.append("IntroCloset floor too small to walk a loop (%s)" % ic_floor.size)
		if ic_floor.position.x > -5.5:
			errors.append("IntroCloset must sit west of the vent gap, got X=%s" % ic_floor.position.x)
	if level.get_node_or_null("Architecture/Ceilings/IntroClosetCeiling") == null:
		errors.append("IntroCloset ceiling missing")
	if level.get_node_or_null("Architecture/Walls/IntroClosetWest") == null:
		errors.append("IntroCloset west wall missing")
	var ic_east := level.get_node_or_null("Architecture/Walls/IntroClosetEast") as CSGBox3D
	var br_west := level.get_node_or_null("Architecture/Walls/BreakRoomWest") as CSGBox3D
	if ic_east == null:
		errors.append("IntroClosetEast missing — closet must not share BreakRoomWest")
	elif absf(ic_east.position.x + 2.66) > 0.08:
		errors.append("IntroClosetEast at X %s, expected -2.66" % ic_east.position.x)
	if ic_east and br_west:
		if absf(ic_east.position.x - br_west.position.x) < 2.0:
			errors.append("closet east wall still shares BreakRoomWest (X %s vs %s)" % [ic_east.position.x, br_west.position.x])
		var kitchen_west_face := br_west.position.x - br_west.size.x * 0.5
		var closet_east_face := ic_east.position.x + ic_east.size.x * 0.5
		var gap := kitchen_west_face - closet_east_face
		if gap < 2.30 or gap > 2.80:
			errors.append("vent gap %.2f m, expected ~2.50 between facing plaster faces" % gap)
		if ic_floor:
			var floor_east := ic_floor.position.x + ic_floor.size.x * 0.5
			if floor_east > closet_east_face + 0.12:
				errors.append("closet floor still reaches the kitchen (east edge %s)" % floor_east)
	if level.get_node_or_null("Architecture/Walls/IntroClosetEast/VentCut") == null:
		errors.append("IntroClosetEast VentCut missing")
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/BreakRoomWindow") != null:
		errors.append("old BreakRoomWindow must be gone")
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/BreakRoomWindowSill") != null:
		errors.append("BreakRoomWindowSill must be gone")
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/BreakRoomWindowHead") != null:
		errors.append("BreakRoomWindowHead must be gone")
	if level.get_node_or_null("Architecture/Walls/BreakRoomWest/WindowCut") != null:
		errors.append("BreakRoomWest WindowCut must be gone")
	var vent_cut := level.get_node_or_null("Architecture/Walls/BreakRoomWest/VentCut") as CSGBox3D
	if vent_cut == null:
		errors.append("BreakRoomWest VentCut missing")
	else:
		if vent_cut.operation != 2:
			errors.append("VentCut must subtract")
		var west := level.get_node_or_null("Architecture/Walls/BreakRoomWest") as CSGBox3D
		if west:
			var vent_y := west.position.y + vent_cut.position.y
			if vent_y > 1.15:
				errors.append("vent opening is not beneath the old window (center Y %s)" % vent_y)
	if level.get_node_or_null("Architecture/VentDuct") == null:
		errors.append("VentDuct missing")
	if level.get_node_or_null("Architecture/VentDuct/KitchenOpening") == null:
		errors.append("kitchen-side vent opening missing")
	if level.get_node_or_null("Architecture/VentDuct/ClosetOpening") == null:
		errors.append("closet-side vent opening missing")
	if level.get_node_or_null("Architecture/VentDuct/DuctFloor") == null:
		errors.append("VentDuct floor missing")
	_check_vent_flush(level, errors)
	_check_playtest_pass(level, errors)
	for tex_path in [
		"res://textures/tex_cardboard.png",
		"res://textures/tex_cardboard_tape.png",
		"res://textures/tex_cardboard_fragile.png",
		"res://textures/tex_cardboard_copy.png",
		"res://textures/tex_carpet_beige.png",
		"res://textures/painting_front_range.png",
		"res://textures/painting_denver_city.png",
	]:
		if not FileAccess.file_exists(tex_path):
			errors.append("%s missing" % tex_path.get_file())
		if not FileAccess.file_exists(tex_path + ".import"):
			errors.append("%s.import missing — web export will skip this texture" % tex_path.get_file())
	if not FileAccess.file_exists("res://materials/mat_carpet.tres"):
		errors.append("mat_carpet.tres missing")
	if level.get_node_or_null("FutureAssetSlots/IntroCloset/ChaosDoor/Slab") == null:
		errors.append("chaos door slab missing")
	else:
		var door := level.get_node_or_null("FutureAssetSlots/IntroCloset/ChaosDoor") as Node3D
		if door and absf(door.position.x + 9.66) > 0.12:
			errors.append("chaos door not recentered on the new west wall (X %s)" % door.position.x)
	var sc_floor := level.get_node_or_null("Architecture/Floors/SupplyClosetFloor") as CSGBox3D
	if sc_floor and (sc_floor.size.x > 3.2 or sc_floor.size.z > 3.2):
		errors.append("existing locked SupplyCloset must stay small")
	var spawn := level.get_node_or_null("Player") as Node3D
	if spawn:
		if absf(spawn.position.x - 3.5) > 0.08 or absf(spawn.position.z - 2.1) > 0.08:
			errors.append("player spawn moved to %s, expected (3.5, 0, 2.1)" % spawn.position)
	var dead_ex := level.get_node_or_null("FutureAssetSlots/CEOOffice/DeadExecutive")
	if dead_ex == null:
		errors.append("dead executive missing")
	elif dead_ex is Node3D:
		var dn := dead_ex as Node3D
		var dp := dn.position
		if absf(dp.x - 32.05) > 0.20 or absf(dp.y - 0.27) > 0.12 or absf(dp.z - 11.45) > 0.20:
			errors.append("dead executive at %s, expected (32.05, 0.27, 11.45)" % dp)
		var dr := dn.rotation_degrees
		if absf(dr.x - 0.0) > 2.0 or absf(dr.y - 18.0) > 2.0:
			errors.append("dead executive parent rot %s, expected (0, 18, 0)" % dr)
		var ceo_mesh := dn.get_node_or_null("CeoDeadMesh") as Node3D
		if ceo_mesh and absf(ceo_mesh.rotation_degrees.x) > 8.0:
			errors.append("CEO mesh X-rot %s — must be face-down (authored, no 180 flip)" % ceo_mesh.rotation_degrees)
		if absf(dn.scale.x - 1.0) > 0.05:
			errors.append("dead executive scale %s, expected 1.0" % dn.scale)
		if dp.z < 9.0:
			errors.append("dead executive blocks the south-entry path")
	if level.get_node_or_null("FutureAssetSlots/CEOOffice/CeoBloodPool") != null:
		errors.append("CeoBloodPool sticker must be gone")
	if level.get_node_or_null("FutureAssetSlots/CEOOffice/BodyPoolLight") != null:
		errors.append("BodyPoolLight must be gone")
	for bi in range(1, 8):
		if level.get_node_or_null("FutureAssetSlots/CEOOffice/BodyBlood_%d" % bi) != null:
			errors.append("BodyBlood_%d blotch must be gone" % bi)
	var dress_src := FileAccess.get_file_as_string("res://scripts/dressing.gd")
	if not dress_src.contains("IntroCloset"):
		errors.append("dressing must build IntroCloset shelves / boxes")
	if not dress_src.contains("tex_cardboard"):
		errors.append("dressing must use dedicated cardboard albedos")
	if not dress_src.contains("tex_carpet_beige") and not dress_src.contains("mat_carpet"):
		errors.append("dressing must apply the beige office carpet")
	if dress_src.contains("FileAccess.file_exists(\"res://textures/tex_cardboard") or dress_src.contains("FileAccess.file_exists(\"res://textures/tex_carpet"):
		errors.append("cardboard / carpet must load() without exists-gate")
	if dress_src.contains("FileAccess.file_exists(\"res://materials/mat_carpet"):
		errors.append("mat_carpet must load() without exists-gate")
	if dress_src.contains("world_dress") or dress_src.contains("shotgun_vm"):
		errors.append("do not invent world_dress.gd / shotgun_vm.gd names")
	if dress_src.contains("Meshy_AI_Photoreal") or dress_src.contains("blood_seepi"):
		errors.append("dressing must not load the Meshy_* blood filename")
	if not dress_src.contains("blood_pool.glb"):
		errors.append("dressing must instance blood_pool.glb")
	if dress_src.contains("FileAccess.file_exists(\"res://models/blood_pool") or dress_src.contains("FileAccess.file_exists(\"res://models/reception_desk"):
		errors.append("blood_pool / reception_desk must load() without exists-gate")
	if dress_src.contains("painting_certificate"):
		errors.append("diploma / certificate textures must not remain on walls")
	if not dress_src.contains("painting_front_range.png") or not dress_src.contains("painting_denver_city.png"):
		errors.append("wall art must load() Front Range / Denver pictures")
	if dress_src.contains("FileAccess.file_exists(\"res://textures/painting_front") or dress_src.contains("FileAccess.file_exists(\"res://textures/painting_denver"):
		errors.append("new wall art must load() without exists-gate")
	if dress_src.contains("name = \"MensDoorAjar\""):
		errors.append("bathroom hall door must not be created")
	if not dress_src.contains("reception_desk.glb"):
		errors.append("dressing must instance reception_desk.glb")
	if dress_src.contains("res://models/ceo_dead.glb"):
		errors.append("old ceo_dead.glb must be replaced by ceo_dead2.glb")
	if not dress_src.contains("ceo_dead2.glb"):
		errors.append("dressing must instance ceo_dead2.glb")
	if not dress_src.contains("refrigerator_open.glb"):
		errors.append("dressing must instance refrigerator_open.glb")
	if not dress_src.contains("kitchen_lunch_table.glb"):
		errors.append("dressing must instance kitchen_lunch_table.glb")
	if not dress_src.contains("bathroom_vanity.glb"):
		errors.append("dressing must instance bathroom_vanity.glb")
	if not dress_src.contains("toiletbowl.glb"):
		errors.append("dressing must instance toiletbowl.glb")
	if not dress_src.contains("fallen_security_guard.glb"):
		errors.append("dressing must instance fallen_security_guard.glb")
	if not dress_src.contains("closed_door.glb"):
		errors.append("dressing must instance closed_door.glb")
	if not dress_src.contains("closed_elevator.glb"):
		errors.append("dressing must instance closed_elevator.glb")
	if not dress_src.contains("mop_and_bucket.glb"):
		errors.append("dressing must instance mop_and_bucket.glb")
	if not dress_src.contains("broken_door.glb"):
		errors.append("dressing must instance broken_door.glb")
	if not dress_src.contains("CEO_couch_coffee_table.glb"):
		errors.append("dressing must instance CEO_couch_coffee_table.glb")
	if not dress_src.contains("blood_decal_1.glb"):
		errors.append("dressing must instance blood_decal_1.glb under the guard")
	if not dress_src.contains("blood_decal_2.glb"):
		errors.append("dressing must instance blood_decal_2.glb on the bathroom wall")
	if dress_src.contains("TODO: wire models/closed_elevator") or dress_src.contains("TODO: wire models/mop_and_bucket"):
		errors.append("elevator / mop TODOs must be dropped once instanced")
	if dress_src.contains("FileAccess.file_exists(\"res://models/ceo_dead") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/shotgun") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/refrigerator") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/kitchen_lunch") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/bathroom_vanity") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/toiletbowl") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/fallen_security") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/closed_door") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/closed_elevator") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/mop_and") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/broken_door") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/CEO_couch") \
			or dress_src.contains("FileAccess.file_exists(\"res://models/blood_decal"):
		errors.append("new Meshy glbs must load() without exists-gate")
	if dress_src.contains("FileAccess.file_exists(\"res://textures/hero/tex-light-oak") \
			or dress_src.contains("FileAccess.file_exists(\"res://textures/hero/denver-fire"):
		errors.append("oak / diorama vista must load() without exists-gate")
	var tv_src := FileAccess.get_file_as_string("res://scripts/tv.gd")
	if not tv_src.contains("tv_not_a_test.png"):
		errors.append("TV missing THIS IS NOT A TEST card")
	if level.get_node_or_null("Ammo_Cubicle") == null:
		errors.append("ammo pickup missing")
	if level.get_node_or_null("Ammo_Break") != null:
		errors.append("second ammo pickup must not exist")
	var dia := level.get_node_or_null("ExteriorDiorama")
	if dia:
		var backdrop := dia.get_node_or_null("Backdrop") as MeshInstance3D
		if backdrop and backdrop.material_override is StandardMaterial3D:
			var bm := backdrop.material_override as StandardMaterial3D
			var tp := ""
			if bm.albedo_texture:
				tp = bm.albedo_texture.resource_path
			if not tp.contains("denver-fire-capitol-demon") and not tp.contains("denver-fire-vista"):
				errors.append("diorama backdrop is %s, expected denver-fire-capitol-demon" % tp)
		var faces := 0
		for fn in ["Backdrop", "FaceN", "FaceS", "FaceFloor", "FaceRoof"]:
			if dia.get_node_or_null(fn) != null:
				faces += 1
		if faces < 5:
			errors.append("diorama missing city faces (%d/5)" % faces)
		if dia.find_child("SmokeParticles", true, false) == null:
			errors.append("diorama smoke particles missing")
	var desk_n := level.get_node_or_null("FutureAssetSlots/CEOOffice/ExecutiveDesk")
	if desk_n == null:
		errors.append("executive desk mesh missing")
	elif desk_n.position.z > 9.15 and desk_n.position.z < 13.85:
		errors.append("desk is on the first window sightline")
	var walls := level.get_node_or_null("WallDressing")
	if walls == null:
		errors.append("wall dressing missing")
	else:
		var boards := 0
		var frames := 0
		for c in walls.get_children():
			var nm := String(c.name)
			if nm.begins_with("Baseboard"):
				boards += 1
			elif nm.ends_with("Art") or nm.ends_with("Frame"):
				frames += 1
		if boards < 10:
			errors.append("too few baseboards (%d)" % boards)
		if frames < 10:
			errors.append("too little wall art (%d)" % frames)
	if level.get_node_or_null("FutureAssetSlots/Bathroom/Toilet_1") == null:
		errors.append("bathroom toilets missing")
	if level.get_node_or_null("FutureAssetSlots/Bathroom/Urinal_0") == null:
		errors.append("bathroom urinals missing")
	if level.get_node_or_null("FutureAssetSlots/Bathroom/Toilet_1/ToiletBowl") == null:
		errors.append("Toilet_1 must instance toiletbowl.glb")
	if level.get_node_or_null("FutureAssetSlots/Bathroom/Urinal_0/ToiletBowl") == null:
		errors.append("Urinal_0 must instance toiletbowl.glb")
	if level.get_node_or_null("FutureAssetSlots/Bathroom/BathroomVanity") == null:
		errors.append("bathroom vanity must instance bathroom_vanity.glb")
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/RefrigeratorOpen") == null:
		errors.append("fridge must instance refrigerator_open.glb")
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/KitchenLunchTable") == null:
		errors.append("table must instance kitchen_lunch_table.glb")
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/FallenSecurityGuard") == null:
		errors.append("fallen security guard missing")
	else:
		var guard := level.get_node_or_null("FutureAssetSlots/BreakRoom/FallenSecurityGuard") as Node3D
		if guard:
			if guard.position.x > 1.15 or guard.position.z < 5.20 or guard.position.z > 6.40:
				errors.append("guard at %s is not leaned in the NW doorway×vent corner" % guard.position)
			if guard.position.y < 0.20 or guard.position.y > 0.70:
				errors.append("guard Y %s — must sit on the floor, not float" % guard.position.y)
			if absf(guard.rotation_degrees.y - 90.0) > 12.0:
				errors.append("guard yaw %s — back must sit on the west wall (yaw ~90)" % guard.rotation_degrees.y)
			if absf(guard.position.x - 3.5) < 0.80 and guard.position.z > 5.8:
				errors.append("guard blocks the north doorway")
			if guard.position.z > 2.70 and guard.position.z < 3.70 and guard.position.x < 0.55:
				errors.append("guard blocks the west vent crawl")
	var guard_puddle := level.get_node_or_null("FutureAssetSlots/BreakRoom/GuardBloodPuddle") as Node3D
	if guard_puddle == null:
		errors.append("bigger blood puddle (blood_decal_1) missing under the guard")
	elif absf(guard_puddle.position.x - 1.02) > 0.35 or absf(guard_puddle.position.z - 5.88) > 0.45:
		errors.append("guard puddle at %s is not under the guard" % guard_puddle.position)
	elif absf(guard_puddle.rotation_degrees.x) < 70.0:
		errors.append("guard puddle is not laid flat on the floor")
	for ch_name in ["BreakRoomChair_01", "BreakRoomChair_02", "BreakRoomChair_03", "BreakRoomChair_04"]:
		var ch := level.get_node_or_null("FutureAssetSlots/BreakRoom/%s" % ch_name)
		if ch is GeometryInstance3D and (ch as GeometryInstance3D).visible:
			errors.append("%s must be deleted / hidden (Rob X'd the chair blocks)" % ch_name)
	var lunch := level.get_node_or_null("FutureAssetSlots/BreakRoom/KitchenLunchTable") as Node3D
	if lunch:
		if absf(lunch.position.x - 3.50) > 0.04 or absf(lunch.position.z - 3.70) > 0.04:
			errors.append("kitchen lunch table moved to %s — leave it and its two chairs" % lunch.position)
		if absf(lunch.scale.x - 0.72) > 0.02:
			errors.append("kitchen lunch table scale %s, expected 0.72" % lunch.scale)
	var fridge_csg := level.get_node_or_null("FutureAssetSlots/BreakRoom/Fridge") as CSGBox3D
	if fridge_csg and fridge_csg.visible:
		errors.append("old CSG fridge must be hidden")
	var table_csg := level.get_node_or_null("FutureAssetSlots/BreakRoom/BreakRoomTable") as CSGBox3D
	if table_csg and table_csg.visible:
		errors.append("old CSG break-room table must be hidden")
	if level.get_node_or_null("FutureAssetSlots/SupplyCloset/LockedDoor_Supply/ClosedElevator") == null:
		errors.append("elevator door must instance closed_elevator.glb")
	if level.get_node_or_null("FutureAssetSlots/SupplyCloset/LockedDoor_Supply/ClosedDoor") != null:
		errors.append("supply / elevator opening must not keep closed_door.glb")
	if level.get_node_or_null("FutureAssetSlots/IntroCloset/MopAndBucket") == null:
		errors.append("mop_and_bucket.glb must instance on IntroCloset")
	else:
		var mop := level.get_node_or_null("FutureAssetSlots/IntroCloset/MopAndBucket") as Node3D
		if mop:
			if mop.position.x > -2.70 or mop.position.x < -4.20:
				errors.append("mop at %s is not on the closet east wall" % mop.position)
			if mop.position.z > 2.70 and mop.position.z < 3.70:
				errors.append("mop blocks the crawl vent mouth (Z %s)" % mop.position.z)
			if mop.position.x < -5.50:
				errors.append("mop blocks the closet aisle")
			if absf(mop.position.x + 3.04) > 0.04 or absf(mop.position.z - 2.02) > 0.04:
				errors.append("mop moved from locked pose (-3.04, 0.476, 2.02) to %s" % mop.position)
			var mop_yaw := mop.rotation_degrees.y
			while mop_yaw < 0.0:
				mop_yaw += 360.0
			while mop_yaw >= 360.0:
				mop_yaw -= 360.0
			if absf(mop_yaw - 270.0) > 8.0:
				errors.append("mop yaw %s — expected 270 (180° flip from 90)" % mop.rotation_degrees.y)
	if level.get_node_or_null("FutureAssetSlots/EastHall/LockedDoor_DeadOffice/ClosedDoor") == null:
		errors.append("dead-office lock must instance closed_door.glb")
	if level.get_node_or_null("FutureAssetSlots/CEOOffice/DeadExecutive/CeoDeadMesh") == null:
		errors.append("CEO must instance ceo_dead2.glb")
	if level.get_node_or_null("FutureAssetSlots/CEOOffice/CeoCouchSet") == null:
		errors.append("CEO office missing CEO_couch_coffee_table.glb")
	else:
		var couches := level.get_node_or_null("FutureAssetSlots/CEOOffice/CeoCouchSet") as Node3D
		if couches:
			if couches.position.x < 26.20 or couches.position.x > 30.40:
				errors.append("couches at %s are not on the wall backing the secretary desk" % couches.position)
			if couches.position.x > 31.20:
				errors.append("couches overlap the CEO body")
			if couches.scale.x < 1.20 or couches.scale.x > 1.80:
				errors.append("couch scale %s is dollhouse or stage, not human furniture" % couches.scale)
	if level.get_node_or_null("FutureAssetSlots/Bathroom/BathroomBloodDrip") == null:
		errors.append("bathroom drip stain (blood_decal_2) missing")
	else:
		var drip := level.get_node_or_null("FutureAssetSlots/Bathroom/BathroomBloodDrip") as Node3D
		if drip:
			if drip.position.x < 1.70 or drip.position.x > 2.05:
				errors.append("drip at %s is not on the empty east bathroom wall" % drip.position)
			if drip.position.z < 10.20 or drip.position.z > 12.40:
				errors.append("drip at %s is not opposite the stalls / north of the door" % drip.position)
			if absf(drip.rotation_degrees.x) > 20.0:
				errors.append("drip was laid on the floor — it must stay vertical on the wall")
	var sg_player := level.get_node_or_null("Player")
	if sg_player and sg_player.find_child("ShotgunMesh", true, false) == null:
		errors.append("hero shotgun must instance shotgun.glb as ShotgunMesh")
	var env_node := level.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node and env_node.environment and env_node.environment.sdfgi_enabled:
		errors.append("SDFGI must stay off")
	if env_node and env_node.environment:
		if absf(env_node.environment.ambient_light_energy - 0.32) > 0.05:
			errors.append("global ambient energy %s — do not retune the money-shot mood" % env_node.environment.ambient_light_energy)
	var win_l := level.get_node_or_null("Lights/WindowLight") as OmniLight3D
	if win_l and absf(win_l.light_energy - 8.8) > 0.20:
		errors.append("WindowLight energy %s, expected 8.8" % win_l.light_energy)
	if ic_floor and ic_floor.material is StandardMaterial3D:
		var fm := ic_floor.material as StandardMaterial3D
		var ftp := fm.albedo_texture.resource_path if fm.albedo_texture else ""
		if not ftp.contains("carpet"):
			errors.append("closet floor is %s, expected beige carpet" % ftp)
	var nh := level.get_node_or_null("Architecture/Floors/NorthHallFloor") as CSGBox3D
	if nh == null or nh.size.x < 2.95:
		errors.append("north hall is not 3.0 m wide")
	var eh := level.get_node_or_null("Architecture/Floors/EastHallFloor") as CSGBox3D
	if eh == null or eh.size.z < 2.95:
		errors.append("east hall is not 3.0 m wide")
	var div := level.get_node_or_null("Architecture/Walls/ReceptionCEODivider") as CSGBox3D
	if div == null:
		errors.append("ReceptionCEODivider missing")
	else:
		if absf(div.position.x - 26.0) > 0.05:
			errors.append("divider X is %s, expected 26" % div.position.x)
		var z0 := div.position.z - div.size.z * 0.5
		var z1 := div.position.z + div.size.z * 0.5
		if z0 > 8.60 or z1 < 14.40:
			errors.append("divider Z span %s–%s, expected 8.53–14.48" % [z0, z1])
	var rec_desk := level.get_node_or_null("FutureAssetSlots/Reception/ReceptionDesk2") as Node3D
	if rec_desk == null:
		errors.append("ReceptionDesk2 missing")
	else:
		var top := rec_desk.get_node_or_null("ReceptionDeskTop") as MeshInstance3D
		if top and top.mesh is BoxMesh:
			var top_y := top.position.y + (top.mesh as BoxMesh).size.y * 0.5
			if absf(top_y - 0.86) > 0.04:
				errors.append("reception counter height %.2f, expected 0.86" % top_y)
		if rec_desk.get_node_or_null("LeatherBack") == null:
			errors.append("reception chair missing on the sit side")
		var back := rec_desk.get_node_or_null("LeatherBack") as Node3D
		if back and back.global_position.x > rec_desk.global_position.x - 0.12:
			errors.append("reception chair not on the sit side after the 180 flip (chair X %s, desk X %s)" % [back.global_position.x, rec_desk.global_position.x])
		var mesh := rec_desk.get_node_or_null("ReceptionDeskMesh") as Node3D
		if mesh == null:
			errors.append("reception_desk.glb mesh missing")
		elif absf(absf(mesh.rotation_degrees.y) - 90.0) > 4.0 or mesh.rotation_degrees.y > 0.0:
			errors.append("reception desk mesh yaw %s, expected −90 (180 flip from +90)" % mesh.rotation_degrees.y)
	var logo := level.get_node_or_null("FutureAssetSlots/Reception/AurumPlate") as MeshInstance3D
	if logo == null:
		errors.append("AURUM plate missing")
	else:
		if not logo.visible:
			errors.append("AURUM plate is not visible")
		if logo.global_position.x > 25.90:
			errors.append("AURUM plate buried in the divider (X %s)" % logo.global_position.x)
	var player_hud := level.get_node_or_null("Player")
	if player_hud:
		var mark := player_hud.find_child("TitleMark", true, false) as Label
		if mark == null or mark.text != "HELLFALL":
			errors.append("HUD TitleMark must be HELLFALL")
	var haunt := level.get_node_or_null("HauntBed") as AudioStreamPlayer
	if haunt == null:
		errors.append("haunt bed loop missing")
	else:
		if absf(haunt.volume_db + 9.0) > 0.15:
			errors.append("HauntBed volume_db %s, expected -9.0" % haunt.volume_db)
		if haunt.process_mode != Node.PROCESS_MODE_ALWAYS:
			errors.append("HauntBed process_mode must be ALWAYS")
		if haunt.autoplay:
			errors.append("HauntBed autoplay must be false")
	var title_play := FileAccess.get_file_as_string("res://scripts/title.gd")
	if not title_play.contains("volume_db = -80"):
		errors.append("title Play must unlock Web Audio at -80 dB before change_scene")
	if title_play.contains("FileAccess.file_exists"):
		errors.append("title web-unlock must load() without FileAccess.file_exists")
	var haunt_src := FileAccess.get_file_as_string("res://scripts/level.gd")
	var haunt_fn := haunt_src.find("func _setup_haunt_bed")
	if haunt_fn < 0:
		errors.append("_setup_haunt_bed missing")
	else:
		var haunt_chunk := haunt_src.substr(haunt_fn, 520)
		if haunt_chunk.contains("FileAccess.file_exists"):
			errors.append("haunt bed must load() without FileAccess.file_exists")
	if not haunt_src.contains("monster_screech_distant.wav"):
		errors.append("level must play monster_screech_distant as a distant bed")
	if not haunt_src.contains("deamon_growl_distant.mp3"):
		errors.append("level must play deamon_growl_distant as a distant bed")
	if haunt_src.contains("FileAccess.file_exists(\"res://audio/deamon") or haunt_src.contains("FileAccess.file_exists(\"res://audio/monster"):
		errors.append("distant beds must load() without FileAccess.file_exists")
	var player_src := FileAccess.get_file_as_string("res://scripts/player.gd")
	if not player_src.contains("shotgun_blast.wav"):
		errors.append("player must reference audio/shotgun_blast.wav")
	if not player_src.contains("shotgun_fire.wav"):
		errors.append("player must fall back to shotgun_fire.wav when blast is missing")
	if player_src.contains("FileAccess.file_exists"):
		errors.append("player must load() shotgun wavs without FileAccess.file_exists")
	if player_src.contains("_load_real_wav"):
		errors.append("player must load() blast wavs directly, no _load_real_wav exists-gate")
	if not player_src.contains("_spawn_impact"):
		errors.append("player must fade air blood in _spawn_impact")
	if not player_src.contains("0.72"):
		errors.append("player impact splat must die at 0.72s")
	var start_rel := player_src.find("func _start_reload")
	if start_rel >= 0:
		var start_chunk := player_src.substr(start_rel, 420)
		if start_chunk.contains("_snd_reload.play()") and not start_chunk.contains("PISTOL"):
			errors.append("shotgun R must not play reload.wav one-shot")
	var tick_rel := player_src.find("func _tick_reload")
	if tick_rel >= 0:
		var tick_chunk := player_src.substr(tick_rel, 420)
		if tick_chunk.contains("_snd_reload.play()"):
			errors.append("shotgun shell insert must not replay reload.wav")
	var vm_src := FileAccess.get_file_as_string("res://scripts/hero_shotgun.gd")
	if not vm_src.contains("shotgun_cocking.wav") or not vm_src.contains("shotgun_reloading.wav"):
		errors.append("hero_shotgun must reference Rob's cock/reload wavs")
	if not vm_src.contains("CockSfx") or not vm_src.contains("ReloadSfx"):
		errors.append("hero_shotgun must have dedicated CockSfx and ReloadSfx")
	if vm_src.contains("FileAccess.file_exists") or vm_src.contains("_load_real_wav"):
		errors.append("hero_shotgun must load() cock/reload wavs without FileAccess.file_exists")
	if not vm_src.contains("const PUMP_TRAVEL := 0.092") or not vm_src.contains("const CYCLE := 0.94"):
		errors.append("shotgun recoil/pump timing must stay 0.092 / 0.94")
	if not vm_src.contains("shotgun.glb"):
		errors.append("hero_shotgun must instance shotgun.glb")
	if vm_src.contains("FileAccess.file_exists(\"res://models/shotgun"):
		errors.append("hero_shotgun must load() shotgun.glb without exists-gate")
	if not vm_src.contains("WeddingBand") or not vm_src.contains("HandL") or not vm_src.contains("HandR"):
		errors.append("hero_shotgun must still build tanned hands + wedding band")
	var enemy_src := FileAccess.get_file_as_string("res://scripts/enemy.gd")
	if enemy_src.contains("FileAccess.file_exists"):
		errors.append("enemy must load() abyssal_stalker.glb without FileAccess.file_exists")
	var ember_src := FileAccess.get_file_as_string("res://scripts/ember.gd")
	if ember_src.contains("FileAccess.file_exists"):
		errors.append("ember must load() ember_demon.glb without FileAccess.file_exists")
	var export_cfg := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_cfg.contains("models/ceo_dead.glb"):
		errors.append("unused ceo_dead.glb must be excluded from the web pack")
	if not vm_src.contains("_show_hands"):
		errors.append("hero_shotgun must keep hands visible on the Meshy mesh")
	var player_src_vm := FileAccess.get_file_as_string("res://scripts/player.gd")
	if player_src_vm.contains("Vector3(0.18, -0.16, -0.34)"):
		errors.append("weapon root still at the old forward pose — pull the shotgun back")
	if player_src_vm.contains("Vector3(0.20, -0.22, -0.16)"):
		errors.append("weapon root z=-0.16 clips the Meshy grip behind the near plane")
	if player_src_vm.contains("Vector3(0.22, -0.20, -0.24)"):
		errors.append("weapon root y=-0.20 puts the hands under the 75° vertical FOV")
	if FileAccess.file_exists("res://scenes/_check_audio.tscn") or FileAccess.file_exists("res://scenes/_ceo_rot_proof.tscn"):
		errors.append("debug helper scenes must not ship")
	var pane := level.get_node_or_null("FutureAssetSlots/CEOOffice/MoneyShotWindow/Pane_02") as CSGBox3D
	if pane and pane.material is StandardMaterial3D:
		if (pane.material as StandardMaterial3D).albedo_color.a > 0.35:
			errors.append("window pane is not transparent glass")
	if not FileAccess.file_exists("res://models/executive_desk.glb"):
		errors.append("executive_desk.glb missing")
	if not FileAccess.file_exists("res://models/coffee_cup.glb"):
		errors.append("coffee_cup.glb missing")
	if not FileAccess.file_exists("res://models/hardcover_book.glb"):
		errors.append("hardcover_book.glb missing")
	if not FileAccess.file_exists("res://models/office_copier.glb"):
		errors.append("office_copier.glb missing")
	if not FileAccess.file_exists("res://models/abyssal_stalker.glb"):
		errors.append("BLOCKED: missing abyssal_stalker.glb")
	var enemy_src := FileAccess.get_file_as_string("res://scripts/enemy.gd")
	if enemy_src.is_empty():
		errors.append("scripts/enemy.gd missing")
	else:
		if not enemy_src.contains("Idle_8"):
			errors.append("idle clip must be Idle_8")
		if not enemy_src.contains("Walking"):
			errors.append("chase clip must be Walking")
		if enemy_src.contains("CLIP_CHASE := \"Running\""):
			errors.append("chase must not be Running")
		if not enemy_src.contains("Axe_Spin_Attack"):
			errors.append("attack clip must be Axe_Spin_Attack")
		if not enemy_src.contains("Shot_and_Fall_Forward"):
			errors.append("death clip must be Shot_and_Fall_Forward")
		if enemy_src.contains("_build_ashwight") or enemy_src.contains("_build_biped") or enemy_src.contains("_build_anims"):
			errors.append("capsule Ashwight builder must be gone")
		if enemy_src.contains("look_at("):
			errors.append("stalker must face with atan2, not look_at")
		if not enemy_src.contains("atan2"):
			errors.append("stalker must face with atan2(+dir.x, +dir.z)")
		var die_at := enemy_src.find("func _die")
		if die_at >= 0:
			var die_chunk := enemy_src.substr(die_at, 420)
			if die_chunk.contains("queue_free("):
				errors.append("death must not queue_free the stalker")
		if FileAccess.file_exists("res://scripts/demon.gd"):
			var demon_src := FileAccess.get_file_as_string("res://scripts/demon.gd")
			if demon_src.contains("_build_ashwight") or demon_src.contains("CapsuleMesh"):
				errors.append("scripts/demon.gd still builds a capsule Ashwight")
		if not enemy_src.contains("deamon_attack2.wav"):
			errors.append("stalker lunge must play deamon_attack2.wav")
		if not enemy_src.contains("deamon_attack.mp3"):
			errors.append("stalker reveal must play deamon_attack.mp3")
	var ember_src := FileAccess.get_file_as_string("res://scripts/ember.gd")
	if ember_src.is_empty():
		errors.append("scripts/ember.gd missing")
	else:
		if not ember_src.contains("Idle_8"):
			errors.append("ember idle clip must be Idle_8")
		if not ember_src.contains("Walking"):
			errors.append("ember chase clip must be Walking")
		if not ember_src.contains("CLIP_ATTACK := \"Attack\""):
			errors.append("ember attack clip must be Attack")
		if not ember_src.contains("Shot_and_Fall_Backward"):
			errors.append("ember death clip must be Shot_and_Fall_Backward")
		if not ember_src.contains("Hit_Reaction"):
			errors.append("ember hit clip must be Hit_Reaction")
		if not ember_src.contains("0.55"):
			errors.append("ember emission cap must be 0.55")
		if ember_src.contains("look_at("):
			errors.append("ember must face with atan2, not look_at")
		if ember_src.contains("Axe_Spin_Attack"):
			errors.append("ember must not use stalker Axe_Spin_Attack")
		if not ember_src.contains("deamon_attack2.wav"):
			errors.append("ember lunge must play deamon_attack2.wav")
		if not ember_src.contains("deamon_growl.wav"):
			errors.append("ember first-see must play deamon_growl.wav")
		var ember_die := ember_src.find("func _die")
		if ember_die >= 0:
			var ember_chunk := ember_src.substr(ember_die, 360)
			if ember_chunk.contains("queue_free("):
				errors.append("death must not queue_free the ember")

	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	var ic_walk := PhysicsRayQueryParameters3D.create(Vector3(-6.16, 1.7, 1.85), Vector3(-6.16, -0.2, 1.85))
	ic_walk.collision_mask = 1
	var ic_hit := space.intersect_ray(ic_walk)
	if ic_hit.is_empty():
		errors.append("IntroCloset is not walkable (no floor under aisle)")
	elif ic_hit.position.y > 0.14:
		errors.append("IntroCloset aisle blocked at %s" % ic_hit.position)
	var ic_door := PhysicsRayQueryParameters3D.create(Vector3(-8.06, 1.7, 4.55), Vector3(-8.06, -0.2, 4.55))
	ic_door.collision_mask = 1
	var ic_door_hit := space.intersect_ray(ic_door)
	if ic_door_hit.is_empty() or ic_door_hit.position.y > 0.14:
		errors.append("IntroCloset west aisle is not walkable")
	var vent_open := PhysicsRayQueryParameters3D.create(Vector3(0.55, 0.45, 3.20), Vector3(-3.10, 0.45, 3.20))
	vent_open.collision_mask = 1
	var vent_hit := space.intersect_ray(vent_open)
	if not vent_hit.is_empty() and vent_hit.position.x > -2.70:
		errors.append("vent opening blocked at %s" % vent_hit.position)
	var sealed := PhysicsRayQueryParameters3D.create(Vector3(0.55, 1.55, 3.20), Vector3(-0.55, 1.55, 3.20))
	sealed.collision_mask = 1
	var sealed_hit := space.intersect_ray(sealed)
	if sealed_hit.is_empty() or sealed_hit.position.x < -0.15:
		errors.append("old window hole is not sealed")
	_check_crawl(level, level.get_node_or_null("Player"), errors)
	var window := Vector3(38.1, 1.7, 11.5)
	for origin in [Vector3(8.5, 1.7, 12.0), Vector3(17.4, 1.7, 12.0), Vector3(3.5, 1.7, 8.8), Vector3(3.5, 1.7, 2.1)]:
		var q := PhysicsRayQueryParameters3D.create(origin, window)
		q.collision_mask = 1
		var hit := space.intersect_ray(q)
		if hit.is_empty() or hit.position.x > 30.0:
			errors.append("LOS leak from %s (hit %s)" % [origin, hit])

	var d1 := level.get_node_or_null("Demon_01")
	var player := level.get_node_or_null("Player")
	if d1 == null:
		errors.append("Demon_01 missing")
	if d1 and d1.get_node_or_null("Rig/Pelvis") != null:
		errors.append("capsule Ashwight Rig/Pelvis still present")
	if d1:
		_check_stalker(d1, errors)
	if d1 == null:
		errors.append("Demon_01 missing for combat QA")
	elif player == null:
		errors.append("player missing")
	else:
		var hp1: float = d1.hp
		player.global_position = Vector3(9.50, 0.0, 8.90)
		var aim: Vector3 = d1.global_position
		player.look_at(Vector3(aim.x, 0.0, aim.z))
		player._head.rotation = Vector3.ZERO
		await process_frame
		player._try_fire()
		await process_frame
		if d1.hp >= hp1:
			errors.append("shotgun did not damage demon 1")
		var shots := 0
		while is_instance_valid(d1) and d1.hp > 0.0 and shots < 8:
			d1.take_damage(28.0)
			shots += 1
		if shots < 3 or shots > 5:
			errors.append("demon died in %d shells, expected 3–5" % shots)
		if is_instance_valid(d1) and d1.hp > 0.0:
			errors.append("demon 1 survived expected shells")
		for _w in 24:
			await process_frame
		if not is_instance_valid(d1):
			errors.append("death must not queue_free the stalker")
		elif d1.hp > 0.0:
			errors.append("stalker did not die")
		var glass_q := PhysicsRayQueryParameters3D.create(Vector3(37.2, 1.2, 11.5), Vector3(40.0, 1.2, 11.5))
		glass_q.collision_mask = 1
		var glass_hit := space.intersect_ray(glass_q)
		if glass_hit.is_empty() or glass_hit.position.x > 39.0:
			errors.append("player can walk through money-shot glass")
		player.take_damage(200.0)
		if not player.dead:
			errors.append("player did not die")

	_finish(errors)


func _check_vent_flush(level: Node, errors: PackedStringArray) -> void:
	var west := level.get_node_or_null("Architecture/Walls/BreakRoomWest") as CSGBox3D
	var east := level.get_node_or_null("Architecture/Walls/IntroClosetEast") as CSGBox3D
	var duct := level.get_node_or_null("Architecture/VentDuct/DuctFloor") as CSGBox3D
	var kitchen_lip := level.get_node_or_null("Architecture/VentDuct/KitchenLip_L") as CSGBox3D
	var closet_lip := level.get_node_or_null("Architecture/VentDuct/ClosetLip_L") as CSGBox3D
	var kitchen_mouth := level.get_node_or_null("Architecture/VentDuct/KitchenOpening") as Node3D
	var closet_mouth := level.get_node_or_null("Architecture/VentDuct/ClosetOpening") as Node3D
	if west == null or east == null or duct == null:
		return
	var kitchen_east_face := west.position.x + west.size.x * 0.5
	var kitchen_west_face := west.position.x - west.size.x * 0.5
	var closet_east_face := east.position.x + east.size.x * 0.5
	var closet_west_face := east.position.x - east.size.x * 0.5
	var duct_min := duct.position.x - duct.size.x * 0.5
	var duct_max := duct.position.x + duct.size.x * 0.5
	# Duct body stays in the gap. A couple cm into wall thickness is OK; rooms are not.
	if duct_max > kitchen_east_face + 0.04:
		errors.append("VentDuct occupies kitchen walkable floor (duct max X %s)" % duct_max)
	if duct_min < closet_west_face - 0.04:
		errors.append("VentDuct occupies closet walkable floor (duct min X %s)" % duct_min)
	if kitchen_lip:
		if kitchen_lip.position.x > kitchen_east_face + 0.08:
			errors.append("kitchen vent lip sticks into the kitchen as a box (X %s)" % kitchen_lip.position.x)
		if absf(kitchen_lip.position.x - west.position.x) > 0.14:
			errors.append("kitchen vent mouth is not wall-flush (lip X %s, wall X %s)" % [kitchen_lip.position.x, west.position.x])
	if closet_lip:
		if closet_lip.position.x < closet_west_face - 0.08:
			errors.append("closet vent lip sticks into the closet as a box (X %s)" % closet_lip.position.x)
		if absf(closet_lip.position.x - east.position.x) > 0.14:
			errors.append("closet vent mouth is not wall-flush (lip X %s, wall X %s)" % [closet_lip.position.x, east.position.x])
	if kitchen_mouth and absf(kitchen_mouth.position.x - west.position.x) > 0.12:
		errors.append("KitchenOpening not on BreakRoomWest")
	if closet_mouth and absf(closet_mouth.position.x - east.position.x) > 0.12:
		errors.append("ClosetOpening not on IntroClosetEast")
	# Shape probes: no duct body on either room's walkable floor.
	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	if space == null:
		return
	var probe := BoxShape3D.new()
	probe.size = Vector3(0.20, 0.30, 0.20)
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = probe
	q.collision_mask = 1
	q.margin = 0.01
	for sample in [Vector3(0.42, 0.40, 3.20), Vector3(-3.05, 0.40, 3.20)]:
		q.transform = Transform3D(Basis(), sample)
		for hit in space.intersect_shape(q, 8):
			var col: Object = hit.get("collider")
			var nm := String(col.name) if col is Node else str(col)
			var pth := String((col as Node).get_path()) if col is Node else ""
			if pth.contains("DuctFloor") or pth.contains("DuctCeiling") or pth.contains("DuctSouth") or pth.contains("DuctNorth"):
				errors.append("VentDuct body occupies walkable floor at %s (%s)" % [sample, nm])
				break


func _check_playtest_pass(level: Node, errors: PackedStringArray) -> void:
	# Stalker chase: no solid blocker on the straight line from the SE hide to the cubicle aisle.
	var part := level.get_node_or_null("FutureAssetSlots/EastHall/CubiclePartition") as CSGBox3D
	if part:
		var part_east := part.position.x + part.size.x * 0.5
		if part_east > 8.90:
			errors.append("cubicle partition still spans the chase lane (east X %s)" % part_east)
	if level.get_node_or_null("MensDoorAjar") != null:
		errors.append("bathroom door still occupies the hall")
	var fallen := level.get_node_or_null("Dread/FallenDoor") as Node3D
	if fallen == null:
		errors.append("FallenDoor missing")
	else:
		var fp := fallen.global_position
		if fp.x > 1.70 or fp.z > 8.20 or fp.z < 7.20:
			errors.append("FallenDoor at %s is not lying inside at the south jamb" % fp)
		if fp.x > 2.00:
			errors.append("FallenDoor still occupies the hall frame")
		if fallen.get_node_or_null("BrokenDoor") == null:
			errors.append("FallenDoor must instance broken_door.glb as BrokenDoor")
		var slab := fallen.get_node_or_null("Slab") as Node3D
		if slab and slab is GeometryInstance3D and (slab as GeometryInstance3D).visible:
			errors.append("greybox FallenDoor Slab is still visible in the bathroom frame")
	var logo := level.get_node_or_null("FutureAssetSlots/Reception/AurumPlate") as MeshInstance3D
	if logo == null or not logo.visible:
		errors.append("logo node must be visible")
	elif logo.mesh == null:
		errors.append("AURUM plate has no mesh")
	var wall_mat := load("res://materials/mat_wall.tres")
	var carpet_mat := load("res://materials/mat_carpet.tres")
	if wall_mat == null or carpet_mat == null:
		errors.append("wall / carpet materials failed to load")
	elif wall_mat == carpet_mat:
		errors.append("carpet material == wall material")
	elif carpet_mat is StandardMaterial3D and wall_mat is StandardMaterial3D:
		var cc := (carpet_mat as StandardMaterial3D).albedo_color
		var wc := (wall_mat as StandardMaterial3D).albedo_color
		if cc.is_equal_approx(wc):
			errors.append("carpet albedo matches plaster — rooms cannot be read")
	var walls := level.get_node_or_null("WallDressing")
	if walls:
		for c in walls.get_children():
			var nm := String(c.name)
			if not (nm.begins_with("Baseboard") or nm.begins_with("ChairRail")):
				continue
			if c is Node3D and _in_l_hall((c as Node3D).global_position):
				errors.append("L-hall still has protruding ridge %s at %s" % [nm, (c as Node3D).global_position])
				break
		for c in walls.get_children():
			if not (c is MeshInstance3D):
				continue
			var mi := c as MeshInstance3D
			var mat := mi.material_override
			if mat is StandardMaterial3D:
				var tex := (mat as StandardMaterial3D).albedo_texture
				if tex and (tex.resource_path.contains("certificate") or tex.resource_path.contains("diploma")):
					errors.append("diploma texture still on wall node %s" % mi.name)
	var west := level.get_node_or_null("Architecture/Walls/BreakRoomWest") as CSGBox3D
	var east := level.get_node_or_null("Architecture/Walls/IntroClosetEast") as CSGBox3D
	var duct := level.get_node_or_null("Architecture/VentDuct/DuctFloor") as CSGBox3D
	var k_lip := level.get_node_or_null("Architecture/VentDuct/KitchenLip_L") as CSGBox3D
	var c_lip := level.get_node_or_null("Architecture/VentDuct/ClosetLip_L") as CSGBox3D
	if west and east and duct:
		var k_west := west.position.x - west.size.x * 0.5
		var k_east := west.position.x + west.size.x * 0.5
		var c_east := east.position.x + east.size.x * 0.5
		var c_west := east.position.x - east.size.x * 0.5
		var d_min := duct.position.x - duct.size.x * 0.5
		var d_max := duct.position.x + duct.size.x * 0.5
		if absf(d_max - k_west) < 0.008 or absf(d_min - c_east) < 0.008:
			errors.append("vent duct shares a plaster plane (z-fight)")
		if k_lip:
			var lip_e := k_lip.position.x + k_lip.size.x * 0.5
			if absf(lip_e - k_east) < 0.008:
				errors.append("kitchen vent lip shares the plaster plane")
		if c_lip:
			var lip_w := c_lip.position.x - c_lip.size.x * 0.5
			if absf(lip_w - c_west) < 0.008:
				errors.append("closet vent lip shares the plaster plane")
	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	if space:
		var hide := Vector3(10.20, 0.96, 8.30)
		var aisle := Vector3(9.30, 0.96, 10.05)
		var q := PhysicsRayQueryParameters3D.create(hide, aisle)
		q.collision_mask = 1
		q.hit_from_inside = false
		var hit := space.intersect_ray(q)
		if not hit.is_empty():
			var col: Object = hit.get("collider")
			var pth := String((col as Node).get_path()) if col is Node else str(col)
			if not pth.contains("Floor") and not pth.contains("Floors"):
				errors.append("stalker chase path blocked at %s (%s)" % [hit.get("position"), pth])
		for sample in [Vector3(3.50, 0.95, 8.80), Vector3(3.55, 0.95, 9.60)]:
			var hall_q := PhysicsRayQueryParameters3D.create(sample + Vector3(0, 0.8, 0), sample + Vector3(0, -1.20, 0))
			hall_q.collision_mask = 1
			var hall_hit := space.intersect_ray(hall_q)
			if hall_hit.is_empty():
				errors.append("north hall not walkable at %s" % sample)
			else:
				var hp: Vector3 = hall_hit.position
				if hp.y > 0.20:
					errors.append("north hall blocked at %s" % hp)
				var hcol: Object = hall_hit.get("collider")
				var hpth := String((hcol as Node).get_path()) if hcol is Node else ""
				if hpth.contains("FallenDoor") or hpth.contains("MensDoor"):
					errors.append("bathroom / fallen door still occupies the hall at %s" % hp)
		var probe := SphereShape3D.new()
		probe.radius = 0.36
		var sq := PhysicsShapeQueryParameters3D.new()
		sq.shape = probe
		sq.collision_mask = 1
		sq.margin = 0.01
		for t in [0.25, 0.50, 0.75]:
			var p: Vector3 = hide.lerp(aisle, t)
			sq.transform = Transform3D(Basis(), p)
			for sh in space.intersect_shape(sq, 8):
				var scol: Object = sh.get("collider")
				var spth := String((scol as Node).get_path()) if scol is Node else ""
				if spth.contains("CubiclePartition") or spth.contains("CubicleDesk") or spth.contains("CubicleChair") or spth.contains("CubicleBin") or spth.contains("CubicleHide") or spth.contains("CubicleFile"):
					errors.append("solid blocker in stalker chase path at %s (%s)" % [p, spth])
					break
	_check_playtest_fix2(level, errors)


func _check_playtest_fix2(level: Node, errors: PackedStringArray) -> void:
	var bath_fl := level.get_node_or_null("Architecture/Floors/BathroomFloor") as CSGBox3D
	if bath_fl:
		var east := bath_fl.position.x + bath_fl.size.x * 0.5
		if east > 2.02:
			errors.append("bathroom floor still overlaps the hall (east X %s)" % east)
		if bath_fl.material is StandardMaterial3D:
			var bm := bath_fl.material as StandardMaterial3D
			if bm.albedo_color.r < 0.55 or bm.albedo_color.g < 0.55:
				errors.append("bathroom floor still reads as dark stone / void (albedo %s)" % bm.albedo_color)
	var thresh := level.get_node_or_null("BathDoorThreshold") as MeshInstance3D
	if thresh == null:
		errors.append("BathDoorThreshold missing")
	elif thresh.mesh is BoxMesh:
		var ts: Vector3 = (thresh.mesh as BoxMesh).size
		if ts.x < 0.38:
			errors.append("bathroom threshold too narrow (%.2f) — need a carpet lip across X 1.80–2.20" % ts.x)
	var bs := level.get_node_or_null("Architecture/Walls/BathroomSouth") as CSGBox3D
	if bs:
		var be := bs.position.x + bs.size.x * 0.5
		if be > 2.00:
			errors.append("BathroomSouth still juts into the hall (east X %s)" % be)
	var bn := level.get_node_or_null("Architecture/Walls/BathroomNorth") as CSGBox3D
	if bn:
		var bne := bn.position.x + bn.size.x * 0.5
		if bne > 2.00:
			errors.append("BathroomNorth still juts into the hall (east X %s)" % bne)
	var conf := level.get_node_or_null("FutureAssetSlots/EastHall/LockedDoor_DeadOffice") as Node3D
	if conf and absf(conf.position.z - 10.50) > 0.08:
		errors.append("conference door at Z %s, expected 10.50 (flush hall wall)" % conf.position.z)
	var glass := level.get_node_or_null("FutureAssetSlots/EastHall/DeadOfficeGlass") as Node3D
	if glass and absf(glass.position.z - 10.50) > 0.08:
		errors.append("conference glass at Z %s still leaks into the hall" % glass.position.z)
	var cub_cut := level.get_node_or_null("Architecture/Walls/EastHallSouth/CubicleOpeningCut") as CSGBox3D
	if cub_cut == null or cub_cut.operation != 2:
		errors.append("cubicle alcove cut missing or not a hole")
	var copy_cut := level.get_node_or_null("Architecture/Walls/EastHallNorth/CopyOpeningCut") as CSGBox3D
	if copy_cut == null or copy_cut.operation != 2:
		errors.append("copy alcove cut missing or not a hole")
	var bath_cut := level.get_node_or_null("Architecture/Walls/NorthHallWest/BathroomDoorCut") as CSGBox3D
	if bath_cut == null or bath_cut.operation != 2:
		errors.append("bathroom hall doorway cut missing — opening must stay an opening")
	var hall_map := level.get_node_or_null("WallDressing/HallMapFrame") as Node3D
	if hall_map and hall_map.global_position.z > 10.70:
		errors.append("HallMap still floats in the east-hall lane (Z %s)" % hall_map.global_position.z)
	var vanity := level.get_node_or_null("FutureAssetSlots/Bathroom/BathroomVanity") as Node3D
	var mirror := level.get_node_or_null("FutureAssetSlots/Bathroom/MirrorWide") as MeshInstance3D
	if vanity == null or mirror == null:
		errors.append("vanity or MirrorWide missing")
	elif mirror.mesh is BoxMesh:
		var mw: float = (mirror.mesh as BoxMesh).size.x
		var vw := 1.9035 * vanity.scale.x
		if absf(vw - mw) > 0.20:
			errors.append("vanity width %.2f does not match mirror span %.2f" % [vw, mw])
		if mw < 2.60:
			errors.append("mirror was shrunk to %.2f — keep the 2.85 m span" % mw)
	if mirror and mirror.material_override is StandardMaterial3D:
		var mm := mirror.material_override as StandardMaterial3D
		if mm.albedo_color.r < 0.70 or mm.albedo_color.g < 0.70:
			errors.append("mirror reads black")
		if mm.metallic < 0.55:
			errors.append("mirror is not silver / metallic glass")
		if not mm.emission_enabled or mm.emission_energy_multiplier < 0.12:
			errors.append("mirror needs a faint silver emission so compat lighting does not crush it to black")
	if level.get_node_or_null("FutureAssetSlots/Bathroom/MirrorFrame_T") == null:
		errors.append("mirror frame missing")
	if level.get_node_or_null("FutureAssetSlots/Bathroom/Bench") is GeometryInstance3D:
		var bench := level.get_node_or_null("FutureAssetSlots/Bathroom/Bench") as GeometryInstance3D
		if bench.visible:
			errors.append("mystery bench block near the urinals must be gone")
	for i in 3:
		var u := level.get_node_or_null("FutureAssetSlots/Bathroom/Urinal_%d" % i) as Node3D
		if u == null:
			errors.append("Urinal_%d missing" % i)
		elif u.position.z < 12.40 or u.position.x < -2.20:
			errors.append("Urinal_%d at %s is not on the back wall (away from stall doors)" % [i, u.position])
	var div0 := level.get_node_or_null("FutureAssetSlots/Bathroom/UrinalDivider_0") as MeshInstance3D
	if div0 and div0.mesh is BoxMesh:
		var ds := (div0.mesh as BoxMesh).size
		if ds.y < 1.25 or ds.z < 0.60:
			errors.append("urinal dividers still tiny (%s) — need taller + deeper privacy screens" % ds)
	var player := level.get_node_or_null("Player")
	if player:
		var hl := player.find_child("HandL", true, false)
		var hr := player.find_child("HandR", true, false)
		var band := player.find_child("WeddingBand", true, false)
		if hl == null or hr == null:
			errors.append("shotgun hands missing (HandL/HandR)")
		elif hl is Node3D and not (hl as Node3D).visible:
			errors.append("HandL is hidden")
		elif hr is Node3D and not (hr as Node3D).visible:
			errors.append("HandR is hidden")
		if band == null:
			errors.append("wedding band missing on the left ring finger")
		var smesh := player.find_child("ShotgunMesh", true, false) as Node3D
		if smesh and smesh.position.z < 0.06:
			errors.append("ShotgunMesh still forward (z %s) — trigger/guard should sit at the screen edge" % smesh.position.z)
		if smesh and smesh.position.z > 0.14:
			errors.append("ShotgunMesh z %s is behind the camera near plane — hands vanish" % smesh.position.z)
	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	if space:
		for sample in [Vector3(3.50, 0.95, 7.40), Vector3(12.50, 0.95, 12.00), Vector3(16.40, 0.95, 12.00)]:
			var hq := PhysicsRayQueryParameters3D.create(sample + Vector3(0, 0.85, 0), sample + Vector3(0, -1.20, 0))
			hq.collision_mask = 1
			var hh := space.intersect_ray(hq)
			if hh.is_empty():
				errors.append("hall floor missing at %s" % sample)
			elif (hh.position as Vector3).y > 0.18:
				errors.append("hall blocked at %s" % hh.position)


func _in_l_hall(p: Vector3) -> bool:
	# North hall (short) + east hall + reception run of the L.
	if p.x > 2.10 and p.x < 4.95 and p.z > 6.55 and p.z < 11.10:
		return true
	if p.x > 5.00 and p.x < 18.20 and p.z > 10.52 and p.z < 13.48:
		return true
	if p.x > 18.10 and p.x < 25.80 and p.z > 6.55 and p.z < 16.45:
		return true
	return false


func _action_has_key(action: String, key: Key) -> bool:
	if not InputMap.has_action(action):
		return false
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and (ev.physical_keycode == key or ev.keycode == key):
			return true
	return false


func _press_c(player: Node) -> void:
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.keycode = KEY_C
	ev.physical_keycode = KEY_C
	ev.unicode = 99
	player._unhandled_input(ev)


func _check_crawl(level: Node, player: Node, errors: PackedStringArray) -> void:
	# Fail-closed: missing crawl plumbing is a hard fail, not a skip.
	if player == null:
		errors.append("player missing for crawl QA")
		return
	if player.get("CRAWL_CAP") == null:
		errors.append("player missing CRAWL_CAP")
		return
	if player.get("crawling") == null:
		errors.append("player missing crawling state")
		return
	if not player.has_method("_toggle_crawl") or not player.has_method("_unhandled_input") or not player.has_method("_apply_stance"):
		errors.append("player missing crawl toggle / stance")
		return
	var crawl_h: float = float(player.CRAWL_CAP)
	var crouch_h: float = float(player.CROUCH_CAP)
	var vent_cut := level.get_node_or_null("Architecture/Walls/BreakRoomWest/VentCut") as CSGBox3D
	if vent_cut == null:
		errors.append("VentCut missing for crawl fit")
		return
	if crawl_h >= vent_cut.size.y:
		errors.append("crawl capsule %.2f does not fit VentCut height %.2f" % [crawl_h, vent_cut.size.y])
	if crawl_h >= crouch_h:
		errors.append("crawl capsule %.2f is not lower than crouch %.2f" % [crawl_h, crouch_h])
	var radius := 0.32
	var pcol := player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if pcol and pcol.shape is CapsuleShape3D:
		radius = (pcol.shape as CapsuleShape3D).radius
	if radius * 2.0 >= vent_cut.size.z:
		errors.append("crawl capsule diameter %.2f does not fit VentCut width %.2f" % [radius * 2.0, vent_cut.size.z])
	var spawn := level.get_node_or_null("Player") as Node3D
	if spawn == null or absf(spawn.position.x - 3.5) > 0.08 or absf(spawn.position.z - 2.1) > 0.08:
		errors.append("player spawn moved to %s, expected (3.5, 0, 2.1)" % (spawn.position if spawn else "?"))

	var was_processing: bool = player.is_physics_processing()
	player.set_physics_process(false)
	player.global_position = Vector3(3.5, 0.0, 2.1)
	player.crawling = false
	player._apply_stance(1.0)
	_press_c(player)
	if not player.crawling:
		errors.append("C did not toggle crawl on")
	player._apply_stance(1.0)
	if pcol and pcol.shape is CapsuleShape3D:
		var cap_on := pcol.shape as CapsuleShape3D
		if absf(cap_on.height - crawl_h) > 0.03:
			errors.append("C crawl capsule height %.2f, expected %.2f" % [cap_on.height, crawl_h])
	_press_c(player)
	if player.crawling:
		errors.append("C did not toggle crawl off in the kitchen")

	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	if space == null:
		errors.append("no physics space for crawl fit")
		player.set_physics_process(was_processing)
		return
	var probe := CapsuleShape3D.new()
	probe.radius = radius
	probe.height = crawl_h
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = probe
	q.collision_mask = 1
	q.exclude = [player.get_rid()]
	q.margin = 0.01
	for sample in [Vector3(0.40, 0.08, 3.20), Vector3(-0.20, 0.08, 3.20), Vector3(-1.33, 0.08, 3.20), Vector3(-2.45, 0.08, 3.20)]:
		q.transform = Transform3D(Basis(), sample + Vector3(0.0, crawl_h * 0.5 + 0.015, 0.0))
		var hits := space.intersect_shape(q, 6)
		for hit in hits:
			var col: Object = hit.get("collider")
			var nm := String(col.name) if col is Node else str(col)
			var path := (col as Node).get_path() if col is Node else NodePath()
			var pth := String(path)
			if nm.contains("Floor") or pth.contains("DuctFloor") or pth.contains("Floors"):
				continue
			errors.append("crawl capsule does not fit VentCut at %s (hit %s)" % [sample, nm])
			break

	player.global_position = Vector3(-1.33, 0.08, 3.20)
	player.crawling = true
	player._apply_stance(1.0)
	_press_c(player)
	if not player.crawling:
		errors.append("crawl-to-stand inside the duct")

	player.global_position = Vector3(-6.16, 0.0, 1.85)
	player.crawling = true
	player._apply_stance(1.0)
	_press_c(player)
	if player.crawling:
		errors.append("cannot stand in the closet aisle")

	player.global_position = Vector3(3.5, 0.0, 2.1)
	player.crawling = true
	player._apply_stance(1.0)
	_press_c(player)
	if player.crawling:
		errors.append("cannot stand in the kitchen")

	_crawl_along(player, Vector3(0.55, 0.0, 3.20), Vector3(-3.20, 0.0, 3.20), "kitchen → IntroCloset", errors)
	_crawl_along(player, Vector3(-3.20, 0.0, 3.20), Vector3(0.55, 0.0, 3.20), "IntroCloset → kitchen", errors)

	player.global_position = Vector3(3.5, 0.0, 2.1)
	player.velocity = Vector3.ZERO
	player.crawling = false
	player._apply_stance(1.0)
	player.set_physics_process(was_processing)


func _crawl_along(player: Node, from: Vector3, to: Vector3, label: String, errors: PackedStringArray) -> void:
	if not player is CharacterBody3D:
		errors.append("player is not a CharacterBody3D")
		return
	var body := player as CharacterBody3D
	body.global_position = from
	body.velocity = Vector3.ZERO
	body.crawling = true
	body._apply_stance(1.0)
	var speed: float = float(body.CRAWL_SPEED)
	var reached := false
	var stuck := 0
	var last := body.global_position
	# Tight-loop move_and_slide steps are smaller than 1/60 * speed.
	# 480 is enough to clear kitchen lip + the 2.6 m duct both ways.
	for _i in 480:
		var flat := to - body.global_position
		flat.y = 0.0
		if flat.length() < 0.42:
			reached = true
			break
		if not body.is_on_floor():
			body.velocity.y -= 9.8 * (1.0 / 60.0)
		var dir := flat.normalized()
		body.velocity.x = dir.x * speed
		body.velocity.z = dir.z * speed
		body.move_and_slide()
		if body.global_position.distance_to(last) < 0.001:
			stuck += 1
			if stuck >= 24:
				break
		else:
			stuck = 0
		last = body.global_position
	if not reached:
		errors.append("cannot crawl %s (ended at %s)" % [label, body.global_position])


func _check_stalker(d1: Node, errors: PackedStringArray) -> void:
	var col := d1.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if col and col.shape is CapsuleShape3D:
		var cap := col.shape as CapsuleShape3D
		if absf(cap.height - 1.92) > 0.06:
			errors.append("stalker capsule height %.2f, expected ~1.92" % cap.height)
		if absf(cap.radius - 0.40) > 0.04:
			errors.append("stalker capsule radius %.2f, expected ~0.40" % cap.radius)
	var visual := d1.get_node_or_null("AbyssalStalker") as Node3D
	if FileAccess.file_exists("res://models/abyssal_stalker.glb"):
		if visual == null:
			errors.append("AbyssalStalker GLB instance missing")
		elif visual.scale.x > 1.05 or visual.scale.x < 0.95:
			errors.append("visual scale %.3f — do not 100x Mixamo bind" % visual.scale.x)
		if d1.has_method("imported_clip_names"):
			var clips: PackedStringArray = d1.imported_clip_names()
			print("STALKER_CLIPS ", ", ".join(clips))
			for need in ["Idle_8", "Walking", "Axe_Spin_Attack", "Shot_and_Fall_Forward"]:
				if not _clip_listed(clips, need):
					errors.append("imported clip missing: %s" % need)
			if _clip_listed(clips, "Running") and d1.get("CLIP_CHASE") == "Running":
				errors.append("chase mapped to Running")
		_check_material_1(d1, errors)
	if d1.get_node_or_null("Rig") != null:
		errors.append("Ashwight Rig still attached")
	if d1 is Node3D and (d1 as Node3D).global_position.z > 9.60:
		errors.append("stalker still in the cubicle doorway — must hide off-spawn")


func _clip_listed(clips: PackedStringArray, want: String) -> bool:
	for n in clips:
		var s := String(n)
		if s == want or s.ends_with("/" + want) or s.ends_with("|" + want) or s.get_file() == want:
			return true
	return false


func _check_material_1(n: Node, errors: PackedStringArray) -> void:
	var found := false
	var stack: Array[Node] = [n]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is MeshInstance3D:
			var mi := cur as MeshInstance3D
			var mesh := mi.mesh
			var surfaces := mesh.get_surface_count() if mesh else 0
			for i in maxi(surfaces, mi.get_surface_override_material_count()):
				var mat := mi.get_active_material(i)
				if mat is StandardMaterial3D:
					var sm := mat as StandardMaterial3D
					if sm.resource_name == "Material_1" or sm.resource_name.ends_with("Material_1"):
						found = true
						if absf(sm.emission_energy_multiplier - 0.32) > 0.06:
							errors.append("Material_1 emission %.2f, expected ~0.32" % sm.emission_energy_multiplier)
		for c in cur.get_children():
			stack.append(c)
	if FileAccess.file_exists("res://models/abyssal_stalker.glb") and not found:
		errors.append("Material_1 not found on stalker")


func _finish(errors: PackedStringArray) -> void:
	if errors.is_empty():
		print("QA_OK title, crouch, crawl, hero shotgun, one Abyssal Stalker 3-5 shells, diorama, LOS, death")
		quit(0)
	else:
		for e in errors:
			push_error("QA_FAIL " + e)
			print("QA_FAIL ", e)
		quit(1)
