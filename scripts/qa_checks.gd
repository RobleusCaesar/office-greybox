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
	if level.get_node_or_null("FutureAssetSlots/BreakRoom/BreakRoomTV") == null:
		errors.append("break room TV missing")
	var dead_ex := level.get_node_or_null("FutureAssetSlots/CEOOffice/DeadExecutive")
	if dead_ex == null:
		errors.append("dead executive missing")
	elif dead_ex is Node3D:
		var dp := (dead_ex as Node3D).position
		if absf(dp.x - 32.0) > 1.2 or absf(dp.z - 11.5) > 1.4:
			errors.append("dead executive at %s, expected ~32, 11.5" % dp)
		if dp.z < 9.0:
			errors.append("dead executive blocks the south-entry path")
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
	var env_node := level.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node and env_node.environment and env_node.environment.sdfgi_enabled:
		errors.append("SDFGI must stay off")
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
		rec_desk = level.find_child("ReceptionDesk", true, false) as Node3D
	var player_hud := level.get_node_or_null("Player")
	if player_hud:
		var mark := player_hud.find_child("TitleMark", true, false) as Label
		if mark == null or mark.text != "HELLFALL":
			errors.append("HUD TitleMark must be HELLFALL")
	if level.get_node_or_null("HauntBed") == null:
		errors.append("haunt bed loop missing")
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

	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
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
		player.global_position = Vector3(9.25, 0.0, 11.55)
		player.look_at(Vector3(9.25, 0.0, 10.2))
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
		print("QA_OK title, crouch, hero shotgun, one Abyssal Stalker 3-5 shells, diorama, LOS, death")
		quit(0)
	else:
		for e in errors:
			push_error("QA_FAIL " + e)
			print("QA_FAIL ", e)
		quit(1)
