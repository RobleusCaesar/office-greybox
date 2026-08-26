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
	if not FileAccess.file_exists("res://textures/hero/title-street-fire.png"):
		errors.append("title-street-fire.png missing")
	if not FileAccess.file_exists("res://textures/hero/shotgun-walnut-steel.png"):
		errors.append("shotgun-walnut-steel.png missing")
	var title_src := FileAccess.get_file_as_string("res://scripts/title.gd")
	if title_src.contains("denver-fire-vista"):
		errors.append("title must not use denver-fire-vista")
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
	if level.get_node_or_null("FutureAssetSlots/CEOOffice/DeadExecutive") == null:
		errors.append("dead executive missing")
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
			if not tp.contains("denver-fire-vista"):
				errors.append("diorama backdrop is %s, expected denver-fire-vista" % tp)
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
	if d1 and d1.get_node_or_null("Rig/Pelvis/Spine/Chest/ShoulderL") == null:
		errors.append("Ashwight missing named bones")
	if d1 and d1.get_node_or_null("Rig/Pelvis/Spine/Chest/Neck/Head/JawL") == null:
		errors.append("Ashwight missing vertical split jaw")
	if d1:
		_check_ashwight_arms(d1, errors)
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
		var glass_q := PhysicsRayQueryParameters3D.create(Vector3(37.2, 1.2, 11.5), Vector3(40.0, 1.2, 11.5))
		glass_q.collision_mask = 1
		var glass_hit := space.intersect_ray(glass_q)
		if glass_hit.is_empty() or glass_hit.position.x > 39.0:
			errors.append("player can walk through money-shot glass")
		player.take_damage(200.0)
		if not player.dead:
			errors.append("player did not die")

	_finish(errors)


func _check_ashwight_arms(d1: Node, errors: PackedStringArray) -> void:
	var names := [
		"UpperArmL", "UpperArmLFlesh", "ForeArmL", "ForeArmLFlesh", "HandLMesh", "HandLClaws",
		"UpperArmR", "UpperArmRFlesh", "ForeArmR", "ForeArmRFlesh", "HandRMesh", "HandRClaws",
	]
	var meshes: Dictionary = {}
	for mi in _collect_meshes(d1):
		meshes[mi.name] = mi
	var rib: MeshInstance3D = meshes.get("Ribcage", null)
	if rib == null:
		errors.append("Ashwight Ribcage missing")
		return
	var hide := rib.material_override
	if hide == null:
		errors.append("Ribcage Hide missing")
		return
	if hide is StandardMaterial3D:
		var hm := hide as StandardMaterial3D
		if hm.uv1_triplanar:
			errors.append("Hide must not be triplanar")
		if hm.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
			errors.append("Hide must not be unlit")
		if hm.albedo_color.r > 0.35:
			errors.append("Hide albedo too light (white-arm risk)")
	var found := 0
	for nm in names:
		var mi: MeshInstance3D = meshes.get(nm, null)
		if mi == null:
			errors.append("Ashwight arm mesh missing: %s" % nm)
			continue
		found += 1
		if mi.material_override != hide:
			errors.append("%s is not the shared Hide material" % nm)
		if mi.material_override is StandardMaterial3D:
			var sm := mi.material_override as StandardMaterial3D
			if sm.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
				errors.append("%s is unlit (white-arm bug)" % nm)
			if sm.albedo_color.r > 0.45 and sm.albedo_color.g > 0.45:
				errors.append("%s albedo is near-white" % nm)
	if found != 12:
		errors.append("expected 12 arm hide meshes, found %d" % found)
	var vein: MeshInstance3D = meshes.get("ArmVeinL", null)
	if vein and vein.material_override is StandardMaterial3D:
		var em := vein.material_override as StandardMaterial3D
		if em.emission_energy_multiplier > 0.55:
			errors.append("arm ember energy %.2f > 0.55" % em.emission_energy_multiplier)
	var core: MeshInstance3D = meshes.get("EmberCore", null)
	if core == null:
		errors.append("EmberCore missing")
	elif core.material_override is StandardMaterial3D:
		var cm := core.material_override as StandardMaterial3D
		if cm.emission_energy_multiplier <= 0.55:
			errors.append("EmberCore is not hotter than arm ember")


func _collect_meshes(n: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	if n is MeshInstance3D:
		out.append(n as MeshInstance3D)
	for c in n.get_children():
		out.append_array(_collect_meshes(c))
	return out


func _finish(errors: PackedStringArray) -> void:
	if errors.is_empty():
		print("QA_OK title, crouch, hero shotgun, one Ashwight 3-5 shells, diorama, LOS, death")
		quit(0)
	else:
		for e in errors:
			push_error("QA_FAIL " + e)
			print("QA_FAIL ", e)
		quit(1)
