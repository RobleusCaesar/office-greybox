extends RefCounted
## Runtime set-dressing: textured parted furniture, dread, diorama, props.


func apply(level: Node3D) -> void:
	_texture_existing(level)
	_breakroom(level)
	_bathroom(level)
	_dread(level)
	_ceo(level)
	_walls(level)
	_diorama(level)
	_ammo(level)
	_emergency(level)


func _mat(path: String) -> Material:
	return load(path)


func _tex_mat(tex_path: String, color: Color = Color.WHITE, rough: float = 0.7, metal: float = 0.0, emit: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	if tex_path != "":
		m.albedo_texture = load(tex_path)
	m.roughness = rough
	m.metallic = metal
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emit
	return m


func _box(parent: Node, name: String, size: Vector3, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO, collide: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = mat
	parent.add_child(mi)
	if collide:
		var sb := StaticBody3D.new()
		sb.collision_layer = 1
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = size
		cs.shape = sh
		sb.add_child(cs)
		mi.add_child(sb)
	return mi


func _quad(parent: Node, name: String, size: Vector2, pos: Vector3, rot: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _set_csg_mat(n: Node, mat: Material) -> void:
	if n is CSGPrimitive3D:
		(n as CSGPrimitive3D).material = mat


func _find(level: Node, path: String) -> Node:
	return level.get_node_or_null(path)


func _texture_existing(level: Node3D) -> void:
	var wood := _mat("res://materials/mat_wood.tres")
	var leather := _mat("res://materials/mat_leather.tres")
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var paper := _mat("res://materials/mat_paper.tres")
	var glass := _mat("res://materials/mat_clear_glass.tres")
	var plant := _mat("res://materials/mat_plant.tres")
	var walnut := _mat("res://materials/mat_walnut.tres")
	var porcelain := _tex_mat("res://textures/tex_porcelain.png", Color(0.92, 0.92, 0.90), 0.18, 0.04)
	var stone := _tex_mat("res://textures/tex_stone.png", Color(0.16, 0.12, 0.10), 0.16, 0.55)
	for p in [
		"FutureAssetSlots/BreakRoom/KitchenetteCounter",
		"FutureAssetSlots/BreakRoom/KitchenetteCabinets",
		"FutureAssetSlots/BreakRoom/BreakRoomTable",
		"FutureAssetSlots/BreakRoom/TablePedestal",
		"FutureAssetSlots/CEOOffice/LiquorCabinet",
		"FutureAssetSlots/CEOOffice/Bookshelf_01",
		"FutureAssetSlots/CEOOffice/Bookshelf_02",
		"FutureAssetSlots/CEOOffice/Bookshelf_03",
		"FutureAssetSlots/Reception/MagazineTable",
		"FutureAssetSlots/Reception/ReceptionSideboard",
		"FutureAssetSlots/Bathroom/Bench",
		"FutureAssetSlots/Bathroom/StallDoor_01",
		"FutureAssetSlots/Bathroom/StallDoor_02",
		"FutureAssetSlots/Bathroom/StallDoor_03",
		"FutureAssetSlots/Bathroom/StallDoor_04",
	]:
		_set_csg_mat(_find(level, p), wood)
	for p in [
		"FutureAssetSlots/BreakRoom/BreakRoomChair_01",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_01_Back",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_02",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_02_Back",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_03",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_03_Back",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_04",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_04_Back",
		"FutureAssetSlots/EastHall/CubicleChair",
		"FutureAssetSlots/EastHall/CubicleChairBack",
		"FutureAssetSlots/CEOOffice/CEOSideChair",
		"FutureAssetSlots/CEOOffice/CEOGuestChair_01",
		"FutureAssetSlots/CEOOffice/CEOGuestChair_02",
		"FutureAssetSlots/Reception/WaitingChair_01",
		"FutureAssetSlots/Reception/WaitingChair_02",
		"FutureAssetSlots/Reception/WaitingChair_03",
		"FutureAssetSlots/Reception/WaitingChair_01_Back",
		"FutureAssetSlots/Reception/WaitingChair_02_Back",
		"FutureAssetSlots/Reception/WaitingChair_03_Back",
	]:
		_set_csg_mat(_find(level, p), leather)
	for p in [
		"FutureAssetSlots/BreakRoom/Fridge",
		"FutureAssetSlots/BreakRoom/Microwave",
		"FutureAssetSlots/BreakRoom/VendingMachine",
		"FutureAssetSlots/EastHall/CubicleDesk",
		"FutureAssetSlots/BreakRoom/TrashBin",
		"FutureAssetSlots/EastHall/CubicleBin",
		"FutureAssetSlots/EastHall/MailSlotBank",
		"FutureAssetSlots/Bathroom/PaperTowel",
	]:
		_set_csg_mat(_find(level, p), metal)
	for p in [
		"FutureAssetSlots/Bathroom/Sink",
		"FutureAssetSlots/Bathroom/Sink_02",
		"FutureAssetSlots/Bathroom/SinkPedestal",
		"FutureAssetSlots/Bathroom/SinkBacksplash",
	]:
		_set_csg_mat(_find(level, p), porcelain)
	_set_csg_mat(_find(level, "FutureAssetSlots/BreakRoom/FridgeHandle"), wood)
	_set_csg_mat(_find(level, "FutureAssetSlots/EastHall/CubicleMonitor"), _tex_mat("res://textures/tv_snow.png", Color.WHITE, 0.4, 0.0, 0.4))
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/PlantFoliage"), plant)
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/PlantPot"), wood)
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/Books_01"), paper)
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/Books_02"), paper)
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/Books_03"), paper)
	_set_csg_mat(_find(level, "Architecture/Floors/CEOOfficeFloor"), walnut if walnut else stone)
	var mirror := _find(level, "FutureAssetSlots/Bathroom/Mirror")
	if mirror:
		_set_csg_mat(mirror, _tex_mat("res://textures/tex_metal.png", Color(0.72, 0.78, 0.82), 0.08, 0.85))
	var win := _find(level, "FutureAssetSlots/CEOOffice/MoneyShotWindow")
	if win:
		for n in ["Pane_01", "Pane_02", "Pane_03"]:
			var pane := win.get_node_or_null(n) as CSGBox3D
			if pane:
				pane.material = glass
				pane.visible = true
				pane.use_collision = true
		var mull := _mat("res://materials/mat_mullion.tres")
		for n in ["Mullion_Left", "Mullion_01", "Mullion_02", "Mullion_Right", "Sill", "Head"]:
			_set_csg_mat(win.get_node_or_null(n), mull)
	var spot2 := _find(level, "DemonSpots/DemonSpot_02")
	if spot2:
		spot2.visible = false
	# Dark walnut divider behind the desk — not beige plaster.
	var div := _find(level, "Architecture/Walls/ReceptionCEODivider")
	if div:
		var walnut_div := _tex_mat("res://textures/tex_walnut.png", Color(0.28, 0.16, 0.10), 0.52)
		walnut_div.uv1_triplanar = true
		walnut_div.uv1_world_triplanar = true
		walnut_div.uv1_scale = Vector3(0.45, 1.85, 0.45)
		_set_csg_mat(div, walnut_div)
	_hide_csg(level, [
		"FutureAssetSlots/CEOOffice/CEODesk",
		"FutureAssetSlots/CEOOffice/CEODeskPedestal_L",
		"FutureAssetSlots/CEOOffice/CEODeskPedestal_R",
		"FutureAssetSlots/CEOOffice/CEOBlotter",
		"FutureAssetSlots/CEOOffice/CEOSideChair",
		"FutureAssetSlots/CEOOffice/CEOLamp",
		"FutureAssetSlots/CEOOffice/CEOLampShade",
		"FutureAssetSlots/EastHall/Copier",
		"FutureAssetSlots/EastHall/CopierLid",
		"FutureAssetSlots/EastHall/CopierTray",
		"FutureAssetSlots/Bathroom/StallVolume_01",
		"FutureAssetSlots/Bathroom/StallVolume_02",
		"FutureAssetSlots/Bathroom/StallVolume_03",
		"FutureAssetSlots/Bathroom/StallVolume_04",
		"FutureAssetSlots/Bathroom/StallDoor_01",
		"FutureAssetSlots/Bathroom/StallDoor_02",
		"FutureAssetSlots/Bathroom/StallDoor_03",
		"FutureAssetSlots/Bathroom/StallDoor_04",
		"FutureAssetSlots/Bathroom/Sink",
		"FutureAssetSlots/Bathroom/Sink_02",
		"FutureAssetSlots/Bathroom/SinkPedestal",
		"FutureAssetSlots/Bathroom/SinkBacksplash",
		"FutureAssetSlots/Bathroom/Mirror",
		"FutureAssetSlots/Reception/ReceptionDesk",
		"FutureAssetSlots/Reception/ReceptionDeskTop",
		"FutureAssetSlots/Reception/ReceptionMonitor",
		"FutureAssetSlots/Reception/BadgeNiche",
		"FutureAssetSlots/Reception/BadgeCard",
	])
	_reception(level)
	_paint_remaining(level)


func _hide_csg(level: Node3D, paths: Array) -> void:
	for p in paths:
		var n := _find(level, p)
		if n is CSGPrimitive3D:
			var c := n as CSGPrimitive3D
			c.visible = false
			c.use_collision = false


func _paint_remaining(n: Node) -> void:
	if n is CSGPrimitive3D:
		var c := n as CSGPrimitive3D
		if c.operation == 0 and c.visible:
			var m: Material = c.material
			var needs := m == null
			if m is StandardMaterial3D:
				needs = (m as StandardMaterial3D).albedo_texture == null and (m as StandardMaterial3D).transparency == BaseMaterial3D.TRANSPARENCY_DISABLED
			if needs:
				var nm := String(c.name)
				if nm.begins_with("Pane") or nm.contains("Glass") or nm.contains("Bottle") or nm.contains("Window") or nm.contains("Mirror"):
					pass
				elif nm.contains("Chair"):
					c.material = _mat("res://materials/mat_leather.tres")
				elif nm.contains("Book") or nm.contains("Paper"):
					c.material = _mat("res://materials/mat_paper.tres")
				elif nm.contains("Plant"):
					c.material = _mat("res://materials/mat_plant.tres")
				elif nm.contains("Stall") or nm.contains("Sink") or nm.contains("Toilet") or nm.contains("Urinal"):
					c.material = _tex_mat("res://textures/tex_porcelain.png", Color(0.9, 0.9, 0.88), 0.2, 0.04)
				else:
					c.material = _mat("res://materials/mat_furniture.tres")
	for ch in n.get_children():
		_paint_remaining(ch)


func _breakroom(level: Node3D) -> void:
	var br := _find(level, "FutureAssetSlots/BreakRoom")
	if br == null:
		return
	var wood := _mat("res://materials/mat_wood.tres")
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var paper := _mat("res://materials/mat_paper.tres")
	# Cabinet drawers + pulls
	_box(br, "Drawer_01", Vector3(0.55, 0.14, 0.04), Vector3(1.4, 0.35, 0.74), wood)
	_box(br, "Drawer_02", Vector3(0.55, 0.14, 0.04), Vector3(2.2, 0.35, 0.74), wood)
	_box(br, "DrawerPull_01", Vector3(0.16, 0.02, 0.03), Vector3(1.4, 0.35, 0.78), metal, Vector3.ZERO, false)
	_box(br, "DrawerPull_02", Vector3(0.16, 0.02, 0.03), Vector3(2.2, 0.35, 0.78), metal, Vector3.ZERO, false)
	# Extra fridge handle bar
	_box(br, "FridgeHandleBar", Vector3(0.03, 0.7, 0.04), Vector3(6.02, 1.15, 0.48), metal, Vector3.ZERO, false)
	# Cubicle keyboard + reception desk parts
	var hall := _find(level, "FutureAssetSlots/EastHall")
	if hall:
		_box(hall, "CubicleKeyboard", Vector3(0.36, 0.02, 0.14), Vector3(8.15, 0.77, 8.62), metal, Vector3.ZERO, false)
		_box(hall, "CubicleDrawer", Vector3(0.28, 0.1, 0.02), Vector3(8.15, 0.42, 8.82), wood, Vector3.ZERO, false)
	# Reception desk is rebuilt in _reception (flipped, light wood).
	# Table papers
	_box(br, "TablePapers", Vector3(0.28, 0.01, 0.2), Vector3(3.7, 0.77, 3.55), paper, Vector3(0, 18, 0), false)
	_instance_glb(br, "res://models/coffee_cup.glb", "CoffeeCup", Vector3(3.52, 0.77, 3.72), Vector3(0, 20, 0), Vector3(1, 1, 1))
	# Wall TV facing into the room
	var tv := Node3D.new()
	tv.name = "BreakRoomTV"
	tv.position = Vector3(6.86, 1.55, 2.15)
	tv.rotation_degrees = Vector3(0, -90, 0)
	_box(tv, "Bezel", Vector3(0.92, 0.56, 0.08), Vector3(0, 0, 0), metal)
	var screen := MeshInstance3D.new()
	screen.name = "Screen"
	var q := QuadMesh.new()
	q.size = Vector2(0.82, 0.46)
	screen.mesh = q
	screen.position = Vector3(0, 0, 0.045)
	tv.add_child(screen)
	tv.set_script(load("res://scripts/tv.gd"))
	br.add_child(tv)


func _bathroom(level: Node3D) -> void:
	var bath := _find(level, "FutureAssetSlots/Bathroom")
	if bath == null:
		return
	var porcelain := _tex_mat("res://textures/tex_porcelain.png", Color(0.90, 0.90, 0.88), 0.18, 0.04)
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var wood := _mat("res://materials/mat_wood.tres")
	# Toilets in the four stalls (west run)
	var tz := [7.95, 9.10, 10.25, 11.40]
	for i in tz.size():
		_toilet(bath, "Toilet_%d" % (i + 1), Vector3(-5.35, 0.0, tz[i]), porcelain, metal)
	# Urinal bank on the north wall
	for i in 3:
		var ux := -0.15 + i * 0.85
		_box(bath, "Urinal_%d" % i, Vector3(0.34, 0.70, 0.26), Vector3(ux, 0.82, 12.58), porcelain)
		_box(bath, "UrinalFlush_%d" % i, Vector3(0.08, 0.08, 0.06), Vector3(ux, 1.24, 12.70), metal, Vector3.ZERO, false)
	# Urinal dividers between the three bowls
	_box(bath, "UrinalDivider_0", Vector3(0.04, 0.95, 0.42), Vector3(0.275, 0.90, 12.62), porcelain)
	_box(bath, "UrinalDivider_1", Vector3(0.04, 0.95, 0.42), Vector3(1.125, 0.90, 12.62), porcelain)
	# Long vanity along the south wall
	_box(bath, "Vanity", Vector3(3.20, 0.08, 0.52), Vector3(0.15, 0.78, 6.88), porcelain)
	_box(bath, "VanityApron", Vector3(3.20, 0.22, 0.06), Vector3(0.15, 0.63, 7.10), porcelain)
	for i in 3:
		var vx := -1.05 + i * 1.05
		_box(bath, "Basin_%d" % i, Vector3(0.48, 0.08, 0.40), Vector3(vx, 0.84, 6.90), porcelain, Vector3.ZERO, false)
		_box(bath, "Faucet_%d" % i, Vector3(0.04, 0.12, 0.16), Vector3(vx, 0.98, 6.74), metal, Vector3.ZERO, false)
	_box(bath, "Soap", Vector3(0.08, 0.12, 0.06), Vector3(-0.2, 1.15, 6.74), _tex_mat("res://textures/tex_porcelain.png", Color(0.7, 0.75, 0.6)), Vector3.ZERO, false)
	# Large smashed mirrors
	var mirror := _tex_mat("res://textures/tex_metal.png", Color(0.78, 0.82, 0.86, 0.92), 0.08, 0.88)
	mirror.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_box(bath, "MirrorWide", Vector3(2.85, 1.15, 0.03), Vector3(0.15, 1.72, 6.68), mirror, Vector3.ZERO, false)
	var crack := _tex_mat("", Color(0.04, 0.04, 0.05, 0.88), 0.9)
	crack.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_box(bath, "MirrorCrack_0", Vector3(0.012, 1.05, 0.01), Vector3(-0.55, 1.70, 6.70), crack, Vector3(0, 0, 18), false)
	_box(bath, "MirrorCrack_1", Vector3(0.90, 0.012, 0.01), Vector3(0.40, 1.95, 6.70), crack, Vector3(0, 0, -22), false)
	_box(bath, "MirrorCrack_2", Vector3(0.012, 0.70, 0.01), Vector3(1.05, 1.55, 6.70), crack, Vector3(0, 0, -12), false)
	# Stall doors hinged on the partitions, not floating mid-gap
	var hinge_z := [7.40, 8.55, 9.70, 10.85]
	for i in hinge_z.size():
		var hinge := Node3D.new()
		hinge.name = "StallDoorHinge_%d" % (i + 1)
		hinge.position = Vector3(-3.50, 0.0, hinge_z[i] + 0.03)
		hinge.rotation_degrees = Vector3(0, 28 + i * 4, 0)
		bath.add_child(hinge)
		_box(hinge, "Slab", Vector3(0.04, 1.86, 0.92), Vector3(0.0, 1.00, 0.48), wood)
	# Ajar MEN door on the north-hall opening (wall now at X=2.0)
	var door := Node3D.new()
	door.name = "MensDoorAjar"
	door.position = Vector3(2.00, 0.0, 8.42)
	door.rotation_degrees = Vector3(0, 52, 0)
	level.add_child(door)
	_box(door, "Slab", Vector3(0.06, 2.08, 1.16), Vector3(0.0, 1.04, 0.58), wood)
	var men := _tex_mat("res://textures/decal_men.png", Color.WHITE, 0.5)
	men.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_quad(door, "MenDecal", Vector2(0.28, 0.28), Vector3(-0.04, 1.55, 0.58), Vector3(0, -90, 0), men)
	# WOMEN on locked supply slab
	var women := _tex_mat("res://textures/decal_women.png", Color.WHITE, 0.5)
	women.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_quad(level, "WomenDecal", Vector2(0.28, 0.28), Vector3(4.88, 1.55, 8.50), Vector3(0, 90, 0), women)


func _oak_mat() -> StandardMaterial3D:
	var path := "res://textures/hero/tex-light-oak.png"
	if not FileAccess.file_exists(path):
		path = "res://textures/tex_wood.png"
	var oak := _tex_mat(path, Color(0.98, 0.90, 0.72), 0.38)
	oak.uv1_triplanar = true
	oak.uv1_world_triplanar = true
	oak.uv1_scale = Vector3(1.35, 1.35, 1.35)
	return oak


func _reception(level: Node3D) -> void:
	var rec := _find(level, "FutureAssetSlots/Reception")
	if rec == null:
		return
	var oak := _oak_mat()
	var dark := _tex_mat("res://textures/tex_walnut.png", Color(0.38, 0.24, 0.14), 0.55)
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var paper := _mat("res://materials/mat_paper.tres")
	var leather := _mat("res://materials/mat_leather.tres")
	# Yaw 180: local +X is the visitor counter (west hall). Local −X is the
	# receptionist / AURUM wall (east). Counter height 0.86 m. Light oak.
	var desk := Node3D.new()
	desk.name = "ReceptionDesk2"
	desk.position = Vector3(24.55, 0.0, 11.50)
	desk.rotation_degrees = Vector3(0, 180, 0)
	rec.add_child(desk)
	_box(desk, "ReceptionDesk", Vector3(1.10, 0.82, 2.55), Vector3(0.0, 0.41, 0.0), oak)
	_box(desk, "ReceptionDeskTop", Vector3(1.24, 0.04, 2.70), Vector3(0.0, 0.84, 0.0), oak)
	# Raised visitor ledge — player's left (world +Z = local −Z).
	_box(desk, "VisitorLedge", Vector3(0.30, 0.10, 1.15), Vector3(0.46, 0.91, -0.62), oak)
	_box(desk, "ReceptionDrawer", Vector3(0.02, 0.10, 0.36), Vector3(0.56, 0.46, 0.85), dark, Vector3.ZERO, false)
	_box(desk, "ReceptionDrawer_02", Vector3(0.02, 0.10, 0.36), Vector3(0.56, 0.46, -0.85), dark, Vector3.ZERO, false)
	# Monitor / keyboard / papers face the wall (local −X = world east).
	_box(desk, "ReceptionMonitor", Vector3(0.07, 0.28, 0.42), Vector3(-0.36, 1.04, 0.16), metal)
	_box(desk, "ReceptionMonitorStand", Vector3(0.08, 0.10, 0.10), Vector3(-0.30, 0.89, 0.16), metal, Vector3.ZERO, false)
	var screen := _tex_mat("res://textures/tv_snow.png", Color(0.08, 0.10, 0.12), 0.35, 0.0, 0.12)
	_quad(desk, "ReceptionScreen", Vector2(0.40, 0.24), Vector3(-0.405, 1.05, 0.16), Vector3(0, -90, 0), screen)
	_box(desk, "ReceptionKeyboard", Vector3(0.14, 0.02, 0.32), Vector3(-0.18, 0.87, 0.16), metal, Vector3.ZERO, false)
	_box(desk, "ReceptionPapers", Vector3(0.18, 0.01, 0.24), Vector3(-0.16, 0.87, -0.55), paper, Vector3(0, 16, 0), false)
	_box(desk, "Stapler", Vector3(0.08, 0.035, 0.03), Vector3(0.10, 0.88, 0.72), metal, Vector3.ZERO, false)
	_box(desk, "Tape", Vector3(0.07, 0.05, 0.07), Vector3(0.14, 0.885, -0.88), metal, Vector3.ZERO, false)
	# Chair on the wall side, under the AURUM sign — back peeks over the desk.
	_box(desk, "LeatherSeat", Vector3(0.44, 0.06, 0.42), Vector3(-0.78, 0.46, 0.0), leather, Vector3.ZERO, false)
	_box(desk, "LeatherBack", Vector3(0.07, 0.78, 0.44), Vector3(-0.96, 0.92, 0.0), leather, Vector3.ZERO, false)
	_box(desk, "LeatherArm_L", Vector3(0.28, 0.14, 0.06), Vector3(-0.78, 0.58, 0.20), leather, Vector3.ZERO, false)
	_box(desk, "LeatherArm_R", Vector3(0.28, 0.14, 0.06), Vector3(-0.78, 0.58, -0.20), leather, Vector3.ZERO, false)
	# Dark walnut panels on the divider west face, then the AURUM plate.
	var panel := _tex_mat("res://textures/tex_walnut.png", Color(0.24, 0.14, 0.08), 0.50)
	panel.uv1_triplanar = true
	panel.uv1_world_triplanar = true
	panel.uv1_scale = Vector3(0.35, 2.2, 0.35)
	for i in 5:
		var z := 9.55 + i * 0.98
		_box(rec, "WalnutPanel_%d" % i, Vector3(0.018, 2.72, 0.92), Vector3(25.888, 1.50, z), panel, Vector3.ZERO, false)
	var plate := _tex_mat("res://textures/hero/aurum-logo.png", Color.WHITE, 0.72)
	plate.metallic = 0.04
	plate.roughness = 0.72
	_box(rec, "AurumPlate", Vector3(0.03, 0.92, 1.45), Vector3(25.86, 1.82, 11.50), plate, Vector3.ZERO, false)


func _dread(level: Node3D) -> void:
	var root := Node3D.new()
	root.name = "Dread"
	level.add_child(root)
	var paper := _mat("res://materials/mat_paper.tres")
	var blood := _mat("res://materials/mat_blood.tres")
	var wood := _mat("res://materials/mat_wood.tres")
	var glass := _mat("res://materials/mat_clear_glass.tres")
	# Scattered papers
	var papers := [
		Vector3(3.2, 0.02, 7.2), Vector3(3.8, 0.02, 10.4), Vector3(8.2, 0.02, 12.15),
		Vector3(11.4, 0.02, 11.4), Vector3(16.2, 0.02, 12.2), Vector3(20.4, 0.02, 11.1),
		Vector3(22.6, 0.02, 8.4), Vector3(27.4, 0.02, 7.8),
	]
	var i := 0
	for p in papers:
		_box(root, "Paper_%d" % i, Vector3(0.22, 0.005, 0.16), p, paper, Vector3(0, float(i * 23), 0), false)
		i += 1
	# Fallen door in north hall
	_box(root, "FallenDoor", Vector3(0.08, 0.9, 2.0), Vector3(3.55, 0.08, 9.6), wood, Vector3(8, 18, 82))
	# Glass shards in EAST HALL only (not money-shot)
	for j in 7:
		var gx := 10.5 + j * 0.55
		_box(root, "Shard_%d" % j, Vector3(0.08, 0.01, 0.05), Vector3(gx, 0.02, 11.35 + (j % 2) * 0.25), glass, Vector3(0, j * 17.0, 12), false)
	# Blood smears — cubicle choke + hall
	_box(root, "BloodCubicle", Vector3(0.9, 0.01, 0.45), Vector3(9.1, 0.015, 10.2), blood, Vector3(0, 30, 0), false)
	_box(root, "BloodHall", Vector3(0.7, 0.01, 0.28), Vector3(12.4, 0.015, 11.55), blood, Vector3(0, -12, 0), false)
	_box(root, "BloodWall", Vector3(0.02, 0.55, 0.35), Vector3(11.08, 0.9, 9.6), blood, Vector3.ZERO, false)
	var hall := _find(level, "FutureAssetSlots/EastHall")
	if hall:
		var copier := _instance_glb(hall, "res://models/office_copier.glb", "OfficeCopier", Vector3(8.35, 0.0, 15.15), Vector3(0, 180, 0), Vector3.ONE)
		_apply_mesh_mats(copier, "res://materials/mat_metal_furn.tres", "res://materials/mat_metal_furn.tres")
		_box_collision(copier, Vector3(0.74, 1.10, 0.68), Vector3(0.0, 0.55, 0.0))


func _ceo(level: Node3D) -> void:
	var ceo := _find(level, "FutureAssetSlots/CEOOffice")
	if ceo == null:
		return
	var leather := _mat("res://materials/mat_leather.tres")
	var wood := _mat("res://materials/mat_wood.tres")
	var paper := _mat("res://materials/mat_paper.tres")
	# Quiet desk off the first window sightline — south wall, knee well faces into the room
	_box(ceo, "LeatherSeat", Vector3(0.48, 0.07, 0.46), Vector3(34.80, 0.50, 8.85), leather, Vector3.ZERO, false)
	_box(ceo, "LeatherBack", Vector3(0.46, 0.62, 0.07), Vector3(34.80, 0.90, 9.12), leather, Vector3.ZERO, false)
	_box(ceo, "LeatherArm_L", Vector3(0.07, 0.20, 0.38), Vector3(34.54, 0.58, 8.85), leather, Vector3.ZERO, false)
	_box(ceo, "LeatherArm_R", Vector3(0.07, 0.20, 0.38), Vector3(35.06, 0.58, 8.85), leather, Vector3.ZERO, false)
	var desk := _instance_glb(ceo, "res://models/executive_desk.glb", "ExecutiveDesk", Vector3(34.80, 0.0, 8.05), Vector3(0, -90, 0), Vector3.ONE)
	_apply_mesh_mats(desk, "res://materials/mat_walnut.tres", "res://materials/mat_metal_furn.tres")
	_desk_collision(desk)
	_instance_glb(ceo, "res://models/hardcover_book.glb", "DeskBook", Vector3(35.05, 0.76, 8.12), Vector3(0, 12, 0), Vector3(1, 1, 1))
	_instance_glb(ceo, "res://models/coffee_cup.glb", "DeskCup", Vector3(34.55, 0.76, 8.00), Vector3(0, -8, 0), Vector3(1, 1, 1))
	# Short bookshelf + fallen books (north wall, off window walk)
	_box(ceo, "ShortShelf", Vector3(1.1, 1.15, 0.3), Vector3(31.4, 0.58, 16.18), wood)
	_box(ceo, "ShortBooks", Vector3(0.9, 0.2, 0.14), Vector3(31.4, 0.85, 16.05), paper, Vector3.ZERO, false)
	_box(ceo, "FallenBook_01", Vector3(0.22, 0.04, 0.16), Vector3(31.9, 0.03, 15.7), paper, Vector3(0, 40, 8), false)
	_box(ceo, "FallenBook_02", Vector3(0.2, 0.04, 0.14), Vector3(31.55, 0.03, 15.45), _tex_mat("res://textures/tex_leather.png", Color(0.25, 0.08, 0.08), 0.7), Vector3(0, -22, 6), false)
	_box(ceo, "FallenBook_03", Vector3(0.18, 0.03, 0.13), Vector3(32.15, 0.025, 15.85), paper, Vector3(0, 70, 4), false)
	# Framed art — mountain on south wall + frame with the plant (right of the window)
	var paint := _tex_mat("res://textures/painting_mountains.png")
	var cert := _tex_mat("res://textures/painting_certificate.png")
	_box(ceo, "FrameMountain", Vector3(1.15, 0.8, 0.04), Vector3(32.2, 1.75, 6.62), wood, Vector3.ZERO, false)
	_quad(ceo, "PaintingMountain", Vector2(1.05, 0.7), Vector3(32.2, 1.75, 6.65), Vector3.ZERO, paint)
	_box(ceo, "FramePlant", Vector3(0.70, 0.88, 0.04), Vector3(35.15, 1.70, 6.62), wood, Vector3.ZERO, false)
	_quad(ceo, "PaintingPlant", Vector2(0.62, 0.78), Vector3(35.15, 1.70, 6.65), Vector3.ZERO, cert)
	_box(ceo, "FrameCert", Vector3(0.55, 0.7, 0.04), Vector3(27.2, 1.7, 14.2), wood, Vector3(0, 90, 0), false)
	_quad(ceo, "PaintingCert", Vector2(0.48, 0.62), Vector3(27.23, 1.7, 14.2), Vector3(0, 90, 0), paint)
	# Dead executive — north of desk, off the window walk (Z~14.3, X~33.4)
	_dead_exec(ceo)


func _dead_exec(ceo: Node) -> void:
	# Proof ceo-mid.png — mid-office, visible from the south door, window ahead.
	var body := Node3D.new()
	body.name = "DeadExecutive"
	body.position = Vector3(32.05, 0.27, 11.45)
	body.rotation_degrees = Vector3(180, 18, 0)
	body.scale = Vector3.ONE
	ceo.add_child(body)
	# Blood + rug stay on the floor (not pitched with the body).
	var rug_a := _tex_mat("res://textures/tex_leather.png", Color(0.42, 0.30, 0.20), 0.85)
	var rug_b := _tex_mat("res://textures/tex_leather.png", Color(0.62, 0.50, 0.36), 0.85)
	var rug_c := _tex_mat("res://textures/tex_stone.png", Color(0.28, 0.28, 0.30), 0.80)
	_box(ceo, "CeoRug_A", Vector3(2.10, 0.006, 0.36), Vector3(32.05, 0.004, 11.10), rug_a, Vector3(0, 18, 0), false)
	_box(ceo, "CeoRug_B", Vector3(2.10, 0.006, 0.36), Vector3(32.05, 0.004, 11.45), rug_b, Vector3(0, 18, 0), false)
	_box(ceo, "CeoRug_C", Vector3(2.10, 0.006, 0.36), Vector3(32.05, 0.004, 11.80), rug_c, Vector3(0, 18, 0), false)
	var pool := _tex_mat("", Color(0.22, 0.015, 0.04, 0.92), 0.85)
	pool.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_box(ceo, "CeoBloodPool", Vector3(1.15, 0.008, 0.62), Vector3(32.05, 0.012, 11.45), pool, Vector3(0, 18, 0), false)
	const GLB := "res://models/ceo_dead.glb"
	if FileAccess.file_exists(GLB) or ResourceLoader.exists(GLB):
		var packed: PackedScene = load(GLB)
		if packed:
			var inst := packed.instantiate() as Node3D
			if inst:
				inst.name = "CeoDeadMesh"
				inst.position = Vector3.ZERO
				inst.scale = Vector3.ONE
				body.add_child(inst)
				return
	# Soft-fail: face toward local +Y, length along +Z. Parent pitch 180 flips
	# the face into the floor. Origin is the torso, so Y=0.27 seats it.
	var skin := _tex_mat("res://textures/tex_leather.png", Color(0.78, 0.58, 0.44), 0.50, 0.0, 0.10)
	var hair := _tex_mat("res://textures/tex_leather.png", Color(0.12, 0.09, 0.07), 0.8)
	var shirt := _tex_mat("res://textures/tex_paper.png", Color(0.94, 0.90, 0.80), 0.65, 0.0, 0.08)
	var suit := _tex_mat("res://textures/tex_leather.png", Color(0.90, 0.72, 0.46), 0.48, 0.0, 0.18)
	var shoe := _tex_mat("res://textures/tex_leather.png", Color(0.10, 0.07, 0.05), 0.4)
	_box(body, "Torso", Vector3(0.42, 0.16, 0.62), Vector3(0.0, 0.16, 0.0), suit, Vector3.ZERO, false)
	_box(body, "Shirt", Vector3(0.18, 0.06, 0.24), Vector3(0.0, 0.22, -0.12), shirt, Vector3.ZERO, false)
	_box(body, "Head", Vector3(0.18, 0.16, 0.20), Vector3(0.0, 0.18, -0.46), skin, Vector3.ZERO, false)
	_box(body, "Hair", Vector3(0.16, 0.08, 0.18), Vector3(0.0, 0.24, -0.48), hair, Vector3.ZERO, false)
	_box(body, "ArmL", Vector3(0.12, 0.10, 0.46), Vector3(-0.30, 0.14, 0.04), suit, Vector3(0, 16, 10), false)
	_box(body, "ArmR", Vector3(0.12, 0.10, 0.46), Vector3(0.30, 0.12, -0.02), suit, Vector3(0, -18, -8), false)
	_box(body, "HandL", Vector3(0.10, 0.06, 0.10), Vector3(-0.40, 0.12, 0.28), skin, Vector3.ZERO, false)
	_box(body, "HandR", Vector3(0.10, 0.06, 0.10), Vector3(0.40, 0.10, -0.26), skin, Vector3.ZERO, false)
	_box(body, "LegL", Vector3(0.12, 0.10, 0.54), Vector3(-0.11, 0.12, 0.54), suit, Vector3.ZERO, false)
	_box(body, "LegR", Vector3(0.12, 0.10, 0.54), Vector3(0.11, 0.12, 0.54), suit, Vector3.ZERO, false)
	_box(body, "ShoeL", Vector3(0.11, 0.08, 0.17), Vector3(-0.11, 0.08, 0.86), shoe, Vector3.ZERO, false)
	_box(body, "ShoeR", Vector3(0.11, 0.08, 0.17), Vector3(0.11, 0.08, 0.86), shoe, Vector3.ZERO, false)


func _city_mat(vista: String) -> StandardMaterial3D:
	var sky := _tex_mat(vista, Color.WHITE, 1.0, 0.0, 2.6)
	sky.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sky.emission_texture = load(vista)
	sky.cull_mode = BaseMaterial3D.CULL_DISABLED
	return sky


func _diorama(level: Node3D) -> void:
	var dia := Node3D.new()
	dia.name = "ExteriorDiorama"
	# Open west face sits just past the glass (world X 38.25). City on every interior face.
	dia.position = Vector3(42.25, 0.0, 11.5)
	level.add_child(dia)
	var vista := "res://textures/hero/denver-fire-capitol-demon.png"
	if not FileAccess.file_exists(vista):
		vista = "res://textures/denver-fire-vista.png"
	var sky := _city_mat(vista)
	# Sealed box: floor, roof, N, S, E. No stone. No gaps beside/above the vista.
	_quad(dia, "Backdrop", Vector2(14.0, 8.0), Vector3(4.40, 3.20, 0.0), Vector3(0, 90, 0), sky)
	_quad(dia, "FaceN", Vector2(8.8, 8.0), Vector3(0.0, 3.20, 6.90), Vector3(0, 180, 0), sky)
	_quad(dia, "FaceS", Vector2(8.8, 8.0), Vector3(0.0, 3.20, -6.90), Vector3(0, 0, 0), sky)
	_quad(dia, "FaceFloor", Vector2(8.8, 14.0), Vector3(0.0, -0.04, 0.0), Vector3(-90, 90, 0), sky)
	_quad(dia, "FaceRoof", Vector2(8.8, 14.0), Vector3(0.0, 6.40, 0.0), Vector3(90, 90, 0), sky)
	# FX stay behind the glass only (world X >= 38.2). Local x >= -4.0.
	var fire_root := Node3D.new()
	fire_root.name = "FireSmoke"
	fire_root.set_script(load("res://scripts/diorama_fx.gd"))
	dia.add_child(fire_root)
	var fire_m := _tex_mat("res://textures/tex_fire.png", Color(1, 0.45, 0.1), 1.0, 0.0, 3.5)
	fire_m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fire_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fire_m.emission_texture = load("res://textures/tex_fire.png")
	var smoke_m := _tex_mat("res://textures/tex_smoke.png", Color(0.3, 0.28, 0.26, 0.55), 1.0, 0.0, 0.2)
	smoke_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Keep FX off the capitol / demon: plaza-level fires at the sides only.
	var fire_pts := [Vector3(2.4, 0.55, -4.6), Vector3(2.6, 0.50, 4.6), Vector3(2.2, 0.48, -2.8)]
	for i in fire_pts.size():
		_quad(fire_root, "Fire_%d" % i, Vector2(1.15, 1.05), fire_pts[i], Vector3(0, 90, 0), fire_m)
	for i in 3:
		_quad(fire_root, "Smoke_%d" % i, Vector2(1.8, 2.0), Vector3(2.8, 3.4 + i * 0.25, -4.2 + i * 4.1), Vector3(0, 90, 0), smoke_m)
	var smoke_p := CPUParticles3D.new()
	smoke_p.name = "SmokeParticles"
	smoke_p.amount = 56
	smoke_p.lifetime = 5.5
	smoke_p.preprocess = 2.0
	smoke_p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	smoke_p.emission_box_extents = Vector3(0.25, 0.2, 5.4)
	smoke_p.direction = Vector3(0, 1, 0)
	smoke_p.spread = 22.0
	smoke_p.gravity = Vector3(0.05, 0.12, 0)
	smoke_p.initial_velocity_min = 0.35
	smoke_p.initial_velocity_max = 1.05
	smoke_p.scale_amount_min = 0.7
	smoke_p.scale_amount_max = 2.1
	var pq := QuadMesh.new()
	pq.size = Vector2(1.15, 1.15)
	smoke_p.mesh = pq
	smoke_p.material_override = smoke_m
	smoke_p.position = Vector3(2.6, 0.7, 0.0)
	fire_root.add_child(smoke_p)
	var sil_tex: Texture2D = load("res://textures/silhouette_person.png")
	var sil_m := StandardMaterial3D.new()
	sil_m.albedo_texture = sil_tex
	sil_m.albedo_color = Color(0.02, 0.02, 0.02, 0.92)
	sil_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sil_m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var people := Node3D.new()
	people.name = "People"
	people.set_script(load("res://scripts/diorama_people.gd"))
	dia.add_child(people)
	for i in 5:
		_quad(people, "Person_%d" % i, Vector2(0.50 + i * 0.04, 1.25 + (i % 2) * 0.12), Vector3(1.4, 0.80, -4.4 + i * 2.2), Vector3(0, -90, 0), sil_m)


func _ammo(level: Node3D) -> void:
	_spawn_ammo(level, Vector3(8.55, 0.82, 8.55), "Ammo_Cubicle")


func _spawn_ammo(level: Node3D, pos: Vector3, name: String) -> void:
	var area := Area3D.new()
	area.name = name
	area.position = pos
	area.set_script(load("res://scripts/ammo_pickup.gd"))
	level.add_child(area)
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(0.28, 0.16, 0.2)
	cs.shape = sh
	area.add_child(cs)
	var wood := _mat("res://materials/mat_wood.tres")
	var metal := _mat("res://materials/mat_metal_furn.tres")
	_box(area, "Crate", Vector3(0.22, 0.1, 0.16), Vector3.ZERO, wood, Vector3.ZERO, false)
	_box(area, "Shells", Vector3(0.16, 0.04, 0.1), Vector3(0, 0.07, 0), metal, Vector3.ZERO, false)
	var lab := Label3D.new()
	lab.text = "E  AMMO"
	lab.font_size = 28
	lab.position = Vector3(0, 0.18, 0)
	lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lab.modulate = Color(0.92, 0.82, 0.55)
	area.add_child(lab)


func _toilet(parent: Node, name: String, pos: Vector3, porcelain: Material, metal: Material) -> void:
	var root := Node3D.new()
	root.name = name
	root.position = pos
	parent.add_child(root)
	_box(root, "Tank", Vector3(0.38, 0.42, 0.16), Vector3(-0.14, 0.62, 0.0), porcelain)
	_box(root, "Bowl", Vector3(0.36, 0.34, 0.48), Vector3(0.10, 0.22, 0.0), porcelain)
	_box(root, "Seat", Vector3(0.34, 0.04, 0.42), Vector3(0.10, 0.40, 0.0), porcelain, Vector3.ZERO, false)
	_box(root, "Lid", Vector3(0.34, 0.36, 0.04), Vector3(-0.12, 0.62, 0.0), porcelain, Vector3.ZERO, false)
	_box(root, "Flush", Vector3(0.06, 0.04, 0.08), Vector3(-0.14, 0.86, 0.0), metal, Vector3.ZERO, false)


func _instance_glb(parent: Node, path: String, name: String, pos: Vector3, rot: Vector3, scl: Vector3) -> Node3D:
	var packed: PackedScene = load(path)
	var inst: Node3D
	if packed:
		inst = packed.instantiate() as Node3D
	else:
		inst = Node3D.new()
	inst.name = name
	inst.position = pos
	inst.rotation_degrees = rot
	inst.scale = scl
	parent.add_child(inst)
	return inst


func _apply_mesh_mats(root: Node, wood_path: String, metal_path: String) -> void:
	var wood := _mat(wood_path)
	var metal := _mat(metal_path)
	_apply_mesh_mats_walk(root, wood, metal)


func _apply_mesh_mats_walk(n: Node, wood: Material, metal: Material) -> void:
	if n is MeshInstance3D:
		var nm := String(n.name)
		(n as MeshInstance3D).material_override = metal if (nm.contains("Metal") or nm.contains("Handle") or nm.contains("Dark") or nm.contains("Hardware")) else wood
	for c in n.get_children():
		_apply_mesh_mats_walk(c, wood, metal)


func _desk_collision(desk: Node3D) -> void:
	_box_collision(desk, Vector3(0.80, 0.06, 1.62), Vector3(0.0, 0.742, 0.0))
	_box_collision(desk, Vector3(0.62, 0.70, 0.30), Vector3(-0.06, 0.35, -0.62))
	_box_collision(desk, Vector3(0.62, 0.70, 0.30), Vector3(-0.06, 0.35, 0.62))


func _trim_seg(root: Node, i: Array, along_x: bool, a0: float, a1: float, fixed: float, mat: Material) -> void:
	var length := a1 - a0
	if length < 0.18:
		return
	var mid := (a0 + a1) * 0.5
	var idx: int = i[0]
	if along_x:
		_box(root, "Baseboard_%d" % idx, Vector3(length, 0.10, 0.04), Vector3(mid, 0.05, fixed), mat, Vector3.ZERO, false)
		_box(root, "ChairRail_%d" % idx, Vector3(length, 0.035, 0.03), Vector3(mid, 1.04, fixed), mat, Vector3.ZERO, false)
	else:
		_box(root, "Baseboard_%d" % idx, Vector3(0.04, 0.10, length), Vector3(fixed, 0.05, mid), mat, Vector3.ZERO, false)
		_box(root, "ChairRail_%d" % idx, Vector3(0.03, 0.035, length), Vector3(fixed, 1.04, mid), mat, Vector3.ZERO, false)
	i[0] = idx + 1


func _trim_span(root: Node, i: Array, along_x: bool, a0: float, a1: float, fixed: float, gaps: Array, mat: Material) -> void:
	var cuts: Array = gaps.duplicate()
	cuts.sort_custom(func(a, b): return a[0] < b[0])
	var cursor := a0
	for g in cuts:
		var lo: float = maxf(a0, g[0])
		var hi: float = minf(a1, g[1])
		if hi <= lo:
			continue
		_trim_seg(root, i, along_x, cursor, lo, fixed, mat)
		cursor = maxf(cursor, hi)
	_trim_seg(root, i, along_x, cursor, a1, fixed, mat)


func _walls(level: Node3D) -> void:
	var root := Node3D.new()
	root.name = "WallDressing"
	level.add_child(root)
	var trim := _mat("res://materials/mat_trim.tres")
	var scuff := _tex_mat("res://textures/tex_scuff.png", Color(0.50, 0.44, 0.36, 0.62), 0.92)
	scuff.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var i := [0]
	# Break room
	_trim_span(root, i, true, 0.20, 6.80, 0.12, [], trim)
	_trim_span(root, i, false, 0.20, 6.40, 0.12, [], trim)
	_trim_span(root, i, false, 0.20, 6.40, 6.88, [], trim)
	# North hall west — skip bathroom entry Z 8.39–9.61 @ X ~2
	_trim_span(root, i, false, 6.58, 13.20, 2.08, [[8.39, 9.61]], trim)
	# North hall east — skip supply / elevator slab
	_trim_span(root, i, false, 6.58, 11.00, 4.92, [[8.05, 8.95]], trim)
	# East hall south — skip cubicle, conference door/glass
	_trim_span(root, i, true, 5.10, 17.85, 10.58, [[7.50, 11.00], [13.20, 14.20], [14.30, 17.80]], trim)
	# East hall north — skip copy alcove
	_trim_span(root, i, true, 5.10, 17.85, 13.42, [[7.50, 12.00]], trim)
	# Reception mouth on west wall
	_trim_span(root, i, false, 6.60, 16.40, 18.10, [[10.50, 13.50]], trim)
	# Reception south / north
	_trim_span(root, i, true, 18.10, 25.85, 6.62, [], trim)
	_trim_span(root, i, true, 18.10, 25.85, 16.38, [], trim)
	# CEO sides of the divider — skip the two side openings
	_trim_span(root, i, false, 6.60, 16.40, 25.86, [[6.60, 8.53], [14.48, 16.40]], trim)
	_trim_span(root, i, false, 8.53, 14.48, 26.14, [], trim)
	# CEO south / north — skip nothing on the long walls
	_trim_span(root, i, true, 26.20, 37.80, 6.62, [], trim)
	_trim_span(root, i, true, 26.20, 37.80, 16.38, [], trim)
	var scuffs := [
		[Vector3(3.40, 0.22, 0.14), Vector2(1.50, 0.30), Vector3(0, 0, 0)],
		[Vector3(5.80, 0.20, 0.14), Vector2(0.90, 0.22), Vector3(0, 0, 0)],
		[Vector3(0.14, 0.24, 2.40), Vector2(1.10, 0.26), Vector3(0, 90, 0)],
		[Vector3(8.90, 0.24, 11.14), Vector2(1.20, 0.28), Vector3(0, 0, 0)],
		[Vector3(13.20, 0.22, 11.14), Vector2(1.00, 0.24), Vector3(0, 0, 0)],
		[Vector3(16.60, 0.22, 12.86), Vector2(1.30, 0.26), Vector3(0, 180, 0)],
		[Vector3(21.20, 0.26, 6.64), Vector2(1.10, 0.28), Vector3(0, 0, 0)],
		[Vector3(26.18, 0.28, 10.40), Vector2(1.20, 0.34), Vector3(0, 90, 0)],
		[Vector3(29.80, 0.24, 6.64), Vector2(1.40, 0.28), Vector3(0, 0, 0)],
		[Vector3(33.40, 0.22, 16.36), Vector2(1.10, 0.24), Vector3(0, 180, 0)],
		[Vector3(36.20, 0.26, 6.64), Vector2(0.85, 0.22), Vector3(0, 0, 0)],
	]
	var j := 0
	for s in scuffs:
		_quad(root, "Scuff_%d" % j, s[1], s[0], s[2], scuff)
		j += 1
	var wood := _mat("res://materials/mat_wood.tres")
	var mountains := _tex_mat("res://textures/painting_mountains.png")
	var cert := _tex_mat("res://textures/painting_certificate.png")
	var city := _tex_mat("res://textures/painting_map.png")
	# Paper on walls — lived-in office, not a furniture catalog
	_frame(root, "HallMap", Vector3(14.60, 1.68, 11.14), Vector2(0.88, 0.62), Vector3(0, 0, 0), wood, city)
	_frame(root, "HallCert", Vector3(16.90, 1.70, 11.14), Vector2(0.46, 0.60), Vector3(0, 0, 0), wood, cert)
	_frame(root, "HallMountains", Vector3(17.20, 1.68, 12.86), Vector2(0.92, 0.64), Vector3(0, 180, 0), wood, mountains)
	_frame(root, "ReceptionMap", Vector3(20.40, 1.72, 16.36), Vector2(0.95, 0.66), Vector3(0, 180, 0), wood, city)
	_frame(root, "ReceptionCertA", Vector3(22.80, 1.70, 16.36), Vector2(0.44, 0.58), Vector3(0, 180, 0), wood, cert)
	_frame(root, "ReceptionMountains", Vector3(21.80, 1.70, 6.64), Vector2(1.02, 0.68), Vector3(0, 0, 0), wood, mountains)
	_frame(root, "DividerCert", Vector3(26.16, 1.68, 10.20), Vector2(0.46, 0.58), Vector3(0, 90, 0), wood, cert)
	_frame(root, "DividerMap", Vector3(26.16, 1.72, 12.55), Vector2(0.80, 0.58), Vector3(0, 90, 0), wood, city)
	_frame(root, "CEONorthMap", Vector3(30.20, 1.72, 16.36), Vector2(0.90, 0.64), Vector3(0, 180, 0), wood, city)
	_frame(root, "CEONorthCert", Vector3(33.10, 1.68, 16.36), Vector2(0.44, 0.56), Vector3(0, 180, 0), wood, cert)
	_frame(root, "BreakCert", Vector3(0.14, 1.58, 4.20), Vector2(0.42, 0.54), Vector3(0, 90, 0), wood, cert)
	_frame(root, "BreakMap", Vector3(6.86, 1.62, 4.80), Vector2(0.70, 0.50), Vector3(0, -90, 0), wood, city)


func _frame(parent: Node, name: String, pos: Vector3, size: Vector2, rot: Vector3, wood: Material, art: Material) -> void:
	_box(parent, name + "Frame", Vector3(size.x + 0.08, size.y + 0.08, 0.035), pos, wood, rot, false)
	var face := pos
	if abs(rot.y) < 1.0:
		face.z += 0.022
	elif abs(rot.y - 180.0) < 1.0:
		face.z -= 0.022
	elif abs(rot.y - 90.0) < 1.0:
		face.x += 0.022
	elif abs(rot.y + 90.0) < 1.0:
		face.x -= 0.022
	_quad(parent, name + "Art", size, face, rot, art)


func _box_collision(parent: Node3D, size: Vector3, pos: Vector3) -> void:
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.position = pos
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	sb.add_child(cs)
	parent.add_child(sb)


func _emergency(level: Node3D) -> void:
	var root := Node3D.new()
	root.name = "EmergencyLights"
	root.set_script(load("res://scripts/emergency_lights.gd"))
	level.add_child(root)
	for p in [Vector3(3.5, 2.7, 8.8), Vector3(3.5, 2.7, 11.6), Vector3(9.0, 2.7, 12.0), Vector3(15.0, 2.7, 12.0), Vector3(22.0, 2.75, 11.5)]:
		var o := OmniLight3D.new()
		o.light_color = Color(1.0, 0.12, 0.08)
		o.light_energy = 1.6
		o.omni_range = 6.5
		o.shadow_enabled = false
		o.position = p
		root.add_child(o)
