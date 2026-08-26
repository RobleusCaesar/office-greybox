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
		player.take_damage(200.0)
		if not player.dead:
			errors.append("player did not die")

	_finish(errors)


func _finish(errors: PackedStringArray) -> void:
	if errors.is_empty():
		print("QA_OK title, crouch, one demon 3-5 shells, diorama, LOS, death")
		quit(0)
	else:
		for e in errors:
			push_error("QA_FAIL " + e)
			print("QA_FAIL ", e)
		quit(1)
