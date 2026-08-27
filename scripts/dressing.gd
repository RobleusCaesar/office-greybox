extends RefCounted
## Runtime set-dressing: textured parted furniture, dread, diorama, props.


func apply(level: Node3D) -> void:
	_texture_existing(level)
	_breakroom(level)
	_intro_closet(level)
	_bathroom(level)
	_dread(level)
	_ceo(level)
	_walls(level)
	_diorama(level)
	_ammo(level)
	_emergency(level)
	_locked_doors(level)
	_flush_hall(level)


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
	_carpet_playable_floors(level)
	_fix_floors(level)
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
		"FutureAssetSlots/BreakRoom/BreakRoomChair_01",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_01_Back",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_02",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_02_Back",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_03",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_03_Back",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_04",
		"FutureAssetSlots/BreakRoom/BreakRoomChair_04_Back",
		"FutureAssetSlots/Bathroom/Bench",
	])
	# Hide CSG stand-ins that Rob's Meshy GLBs replace. Keep collision footprints.
	_hide_visual(_find(level, "FutureAssetSlots/BreakRoom/Fridge"))
	_hide_visual(_find(level, "FutureAssetSlots/BreakRoom/FridgeHandle"))
	_hide_visual(_find(level, "FutureAssetSlots/BreakRoom/BreakRoomTable"))
	_hide_visual(_find(level, "FutureAssetSlots/BreakRoom/TablePedestal"))
	_reception(level)
	_paint_remaining(level)


func _hide_csg(level: Node3D, paths: Array) -> void:
	for p in paths:
		var n := _find(level, p)
		if n is CSGPrimitive3D:
			var c := n as CSGPrimitive3D
			c.visible = false
			c.use_collision = false


func _hide_visual(n: Node) -> void:
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).visible = false
	elif n is Node3D:
		(n as Node3D).visible = false


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
	# load() only — do not exists-gate. Open-door fridge on the kitchenette footprint.
	# Mesh AABB y −0.953..0.951, depth 1.30 (door open). Seat on the floor at the old fridge.
	_instance_glb(br, "res://models/refrigerator_open.glb", "RefrigeratorOpen", Vector3(6.40, 0.952, 0.65), Vector3(0, 0, 0), Vector3.ONE)
	# Lunch table: mesh AABB y −0.533..0.533, height 1.07. Scale 0.72 → ~0.76 m top so the cup / papers still sit.
	_instance_glb(br, "res://models/kitchen_lunch_table.glb", "KitchenLunchTable", Vector3(3.50, 0.384, 3.70), Vector3(0, 0, 0), Vector3(0.72, 0.72, 0.72))
	# Fallen guard — NW corner (doorway wall × crawl-hole wall). Lie as authored so
	# the back is on the carpet (a 90° roll arched the torso and read as floating).
	# Yaw tucks the shoulder into the north plaster; X keeps him on the west wall.
	var guard := _instance_glb(br, "res://models/fallen_security_guard.glb", "FallenSecurityGuard", Vector3(0.44, 0.48, 5.66), Vector3(0, 14, 0), Vector3.ONE)
	_seat_on_floor(guard)
	# Authored sit/slump leaves a visible air gap once AABB-seated — plant him.
	guard.position.y -= 0.14
	_box_collision(guard, Vector3(0.70, 0.36, 1.70), Vector3(0.0, 0.0, 0.0))
	# Cubicle keyboard + reception desk parts
	var hall := _find(level, "FutureAssetSlots/EastHall")
	if hall:
		_box(hall, "CubicleKeyboard", Vector3(0.36, 0.02, 0.14), Vector3(8.05, 0.77, 8.48), metal, Vector3.ZERO, false)
		_box(hall, "CubicleDrawer", Vector3(0.28, 0.1, 0.02), Vector3(8.05, 0.42, 8.68), wood, Vector3.ZERO, false)
	# Reception desk is rebuilt in _reception (flipped, light wood).
	# Table papers / cup rest on the new tabletop (~0.77 m).
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


func _cardboard_mat(path: String, rough: float = 0.84) -> StandardMaterial3D:
	# Dedicated albedo on BoxMesh / quads — same care as tv.gd, not a CSG wood tint.
	# load() only. White albedo so the authored PNG reads, not a beige smear.
	var m := StandardMaterial3D.new()
	m.albedo_color = Color.WHITE
	m.albedo_texture = load(path)
	m.roughness = rough
	m.metallic = 0.0
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return m


func _office_carpet() -> StandardMaterial3D:
	var m: Material = _mat("res://materials/mat_carpet.tres")
	if m is StandardMaterial3D:
		return m as StandardMaterial3D
	# Soft-fail authored the same way as _tex_mat — load() the PNG, no exists-gate.
	var carpet := _tex_mat("res://textures/tex_carpet_beige.png", Color.WHITE, 0.92)
	carpet.uv1_triplanar = true
	carpet.uv1_world_triplanar = true
	carpet.uv1_scale = Vector3(0.85, 0.85, 0.85)
	return carpet


func _carpet_playable_floors(level: Node3D) -> void:
	# Closet + kitchen + halls were sharing a near-black polished stone.
	# CEO stays walnut. Bathroom stays porcelain/stone.
	var carpet := _office_carpet()
	for p in [
		"Architecture/Floors/IntroClosetFloor",
		"Architecture/Floors/BreakRoomFloor",
		"Architecture/Floors/NorthHallFloor",
		"Architecture/Floors/EastHallFloor",
		"Architecture/Floors/CornerFloor",
		"Architecture/Floors/CubicleFloor",
		"Architecture/Floors/CopyAlcoveFloor",
		"Architecture/Floors/ReceptionFloor",
		"Architecture/Floors/DeadOfficeFloor",
	]:
		_set_csg_mat(_find(level, p), carpet)


func _sheet_metal() -> StandardMaterial3D:
	var m := _tex_mat("res://textures/tex_sheet_metal.png", Color(0.72, 0.74, 0.76), 0.42, 0.78)
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(1.6, 1.6, 1.6)
	return m


func _intro_closet(level: Node3D) -> void:
	var ic := _find(level, "FutureAssetSlots/IntroCloset")
	if ic == null:
		return
	var metal := _sheet_metal()
	for p in [
		"Architecture/VentDuct/DuctFloor",
		"Architecture/VentDuct/DuctCeiling",
		"Architecture/VentDuct/DuctSouth",
		"Architecture/VentDuct/DuctNorth",
		"Architecture/VentDuct/KitchenLip_L",
		"Architecture/VentDuct/KitchenLip_R",
		"Architecture/VentDuct/KitchenLip_T",
		"Architecture/VentDuct/KitchenLip_B",
		"Architecture/VentDuct/ClosetLip_L",
		"Architecture/VentDuct/ClosetLip_R",
		"Architecture/VentDuct/ClosetLip_T",
		"Architecture/VentDuct/ClosetLip_B",
	]:
		_set_csg_mat(_find(level, p), metal)
	# Floor-to-ceiling units on N / S / W. East wall is the vent — no shelves.
	# Recentered for the gapped closet (east wall at X=-2.66, west at X=-9.66).
	_shelf_run(ic, "South", Vector3(-9.14, 0.0, 0.10), Vector3.RIGHT, Vector3.BACK, 6.16, 5)
	_shelf_run(ic, "North", Vector3(-9.14, 0.0, 6.32), Vector3.RIGHT, Vector3.FORWARD, 6.16, 5)
	_shelf_run(ic, "WestS", Vector3(-9.56, 0.0, 0.56), Vector3.BACK, Vector3.RIGHT, 2.06, 2)
	_shelf_run(ic, "WestN", Vector3(-9.56, 0.0, 3.90), Vector3.BACK, Vector3.RIGHT, 2.24, 2)
	_floor_cartons(ic)
	# Mop: east wall, RIGHT of the vent mouth (south). Scale 0.50 → ~0.95 m. load() only.
	# Mesh AABB y −0.952..0.951, 1.64 × 1.90 × 1.27. Do not block the crawl hole or the aisle.
	var mop := _instance_glb(ic, "res://models/mop_and_bucket.glb", "MopAndBucket", Vector3(-3.04, 0.476, 2.02), Vector3(0, 90, 0), Vector3(0.50, 0.50, 0.50))
	_box_collision(mop, Vector3(0.42, 0.90, 0.52), Vector3(0.0, 0.0, 0.0))
	var br := _find(level, "FutureAssetSlots/BreakRoom")
	if br:
		_vent_cover(br)
	# Extra handle rose on the sealed door so it reads as hardware, not a box.
	var door := ic.get_node_or_null("ChaosDoor")
	if door:
		var furn_metal := _mat("res://materials/mat_metal_furn.tres")
		var slab_mat := _tex_mat("res://textures/tex_walnut.png", Color(0.38, 0.24, 0.14), 0.58)
		slab_mat.uv1_triplanar = true
		slab_mat.uv1_world_triplanar = true
		slab_mat.uv1_scale = Vector3(1.1, 1.8, 1.1)
		_set_csg_mat(door.get_node_or_null("Slab"), slab_mat)
		var frame_mat := _tex_mat("res://textures/tex_walnut.png", Color(0.48, 0.32, 0.18), 0.62)
		frame_mat.uv1_triplanar = true
		frame_mat.uv1_world_triplanar = true
		for fn in ["Frame_L", "Frame_R", "Frame_Head"]:
			_set_csg_mat(door.get_node_or_null(fn), frame_mat)
		_box(door, "HandleRose", Vector3(0.03, 0.14, 0.14), Vector3(0.08, 1.00, 0.30), furn_metal, Vector3.ZERO, false)
		_box(door, "HandleLever", Vector3(0.045, 0.045, 0.22), Vector3(0.12, 1.00, 0.20), furn_metal, Vector3.ZERO, false)
		_box(door, "LockCylinder", Vector3(0.04, 0.04, 0.04), Vector3(0.09, 1.00, 0.14), furn_metal, Vector3.ZERO, false)
		_box(door, "KickPlate", Vector3(0.02, 0.16, 0.86), Vector3(0.06, 0.12, 0.0), furn_metal, Vector3.ZERO, false)


func _shelf_run(parent: Node, stem: String, origin: Vector3, along: Vector3, inward: Vector3, length: float, n_bays: int) -> void:
	var wood := _mat("res://materials/mat_wood.tres")
	var metal := _mat("res://materials/mat_metal_furn.tres")
	along = along.normalized()
	inward = inward.normalized()
	var depth := 0.44
	var board_t := 0.028
	var post_w := 0.034
	var post_h := 2.80
	var heights := [0.20, 0.74, 1.28, 1.82, 2.36]
	var bay := length / float(n_bays)
	var board_sz: Vector3 = along.abs() * (bay - 0.048) + inward.abs() * (depth - 0.052) + Vector3.UP * board_t
	for i in n_bays + 1:
		var base := origin + along * (float(i) * bay)
		var back := base + inward * 0.018
		var front := base + inward * (depth - 0.018)
		back.y = post_h * 0.5
		front.y = post_h * 0.5
		_box(parent, "%s_UprightB_%d" % [stem, i], Vector3(post_w, post_h, post_w), back, metal)
		_box(parent, "%s_UprightF_%d" % [stem, i], Vector3(post_w, post_h, post_w), front, metal)
	for i in n_bays:
		var mid := origin + along * ((float(i) + 0.5) * bay) + inward * (depth * 0.5)
		for hi in heights.size():
			var pos := mid
			pos.y = heights[hi]
			_box(parent, "%s_Board_%d_%d" % [stem, i, hi], board_sz, pos, wood)
			var rail := mid
			rail.y = heights[hi] + 0.06
			rail = origin + along * ((float(i) + 0.5) * bay) + inward * 0.012
			rail.y = heights[hi] + 0.055
			var rail_sz: Vector3 = along.abs() * (bay - 0.06) + inward.abs() * 0.012 + Vector3.UP * 0.018
			_box(parent, "%s_Rail_%d_%d" % [stem, i, hi], rail_sz, rail, metal, Vector3.ZERO, false)
			_stock_board(parent, stem, i, hi, pos, along, inward, bay - 0.08, depth - 0.08, heights[hi] + board_t * 0.5)


func _stock_board(parent: Node, stem: String, bay: int, hi: int, board_pos: Vector3, along: Vector3, inward: Vector3, board_len: float, board_depth: float, board_top: float) -> void:
	var catalog := [
		["res://textures/tex_cardboard.png", Vector3(0.28, 0.18, 0.22), 0.84],
		["res://textures/tex_cardboard_tape.png", Vector3(0.32, 0.20, 0.26), 0.56],
		["res://textures/tex_cardboard_fragile.png", Vector3(0.30, 0.22, 0.24), 0.82],
		["res://textures/tex_cardboard_copy.png", Vector3(0.36, 0.16, 0.26), 0.80],
		["res://textures/tex_cardboard.png", Vector3(0.22, 0.14, 0.18), 0.84],
		["res://textures/tex_cardboard_tape.png", Vector3(0.26, 0.24, 0.22), 0.56],
	]
	var n_boxes := 2 if board_len > 0.85 else 1
	if hi == 4:
		n_boxes = 1
	for k in n_boxes:
		var spec: Array = catalog[(bay * 7 + hi * 3 + k + stem.length()) % catalog.size()]
		var tex: String = spec[0]
		var raw: Vector3 = spec[1]
		# Keep the box on the board: depth along inward, width along the run.
		var size := along.abs() * minf(raw.x, board_len * 0.42) + Vector3.UP * raw.y + inward.abs() * minf(raw.z, board_depth * 0.82)
		if size.x < 0.08:
			size.x = raw.z
		if size.z < 0.08:
			size.z = raw.x
		var t := (float(k) + 0.5) / float(n_boxes) - 0.5
		var pos := board_pos + along * (t * board_len * 0.72) + inward * (0.03 * float(k - 1))
		pos.y = board_top + size.y * 0.5
		# Face the aisle so FRAGILE / COPY PAPER read at shelf distance.
		var yaw := _face_yaw(inward) + float(((bay + hi * 2 + k) % 5) - 2) * 3.0
		_carton(parent, "%s_Box_%d_%d_%d" % [stem, bay, hi, k], size, pos, yaw, tex, false)


func _face_yaw(inward: Vector3) -> float:
	if inward.z > 0.5:
		return 0.0
	if inward.z < -0.5:
		return 180.0
	if inward.x > 0.5:
		return -90.0
	if inward.x < -0.5:
		return 90.0
	return 0.0


func _carton(parent: Node, name: String, size: Vector3, pos: Vector3, yaw: float, face_tex: String, collide: bool) -> void:
	var root := Node3D.new()
	root.name = name
	root.position = pos
	root.rotation_degrees = Vector3(0, yaw, 0)
	parent.add_child(root)
	var card := _cardboard_mat("res://textures/tex_cardboard.png")
	var face := _cardboard_mat(face_tex)
	var tape := _cardboard_mat("res://textures/tex_cardboard_tape.png", 0.54)
	var hx := size.x * 0.5
	var hy := size.y * 0.5
	var hz := size.z * 0.5
	_quad(root, "Front", Vector2(size.x, size.y), Vector3(0, 0, hz + 0.001), Vector3(0, 0, 0), face)
	_quad(root, "Back", Vector2(size.x, size.y), Vector3(0, 0, -hz - 0.001), Vector3(0, 180, 0), card)
	_quad(root, "Left", Vector2(size.z, size.y), Vector3(-hx - 0.001, 0, 0), Vector3(0, -90, 0), card)
	_quad(root, "Right", Vector2(size.z, size.y), Vector3(hx + 0.001, 0, 0), Vector3(0, 90, 0), card)
	_quad(root, "Top", Vector2(size.x, size.z), Vector3(0, hy + 0.001, 0), Vector3(-90, 0, 0), tape)
	_quad(root, "Bottom", Vector2(size.x, size.z), Vector3(0, -hy - 0.001, 0), Vector3(90, 0, 0), card)
	var body := _box(root, "Body", size, Vector3.ZERO, card, Vector3.ZERO, collide)
	body.visible = false


func _floor_cartons(ic: Node) -> void:
	# A few on the floor. Leave the aisle, vent mouth, and chaos door clear.
	# Recentered: old positions minus 2.66 m (closet shifted west off BreakRoomWest).
	_carton(ic, "Floor_Fragile", Vector3(0.52, 0.40, 0.40), Vector3(-8.51, 0.20, 1.05), 18.0, "res://textures/tex_cardboard_fragile.png", true)
	_carton(ic, "Floor_Copy", Vector3(0.46, 0.28, 0.36), Vector3(-8.21, 0.14, 1.38), -12.0, "res://textures/tex_cardboard_copy.png", true)
	_carton(ic, "Floor_Tape", Vector3(0.38, 0.24, 0.32), Vector3(-8.36, 0.12, 5.55), 8.0, "res://textures/tex_cardboard_tape.png", true)
	_carton(ic, "Floor_Copy2", Vector3(0.42, 0.22, 0.34), Vector3(-8.06, 0.11, 5.22), -22.0, "res://textures/tex_cardboard_copy.png", true)
	_carton(ic, "Floor_Plain", Vector3(0.34, 0.20, 0.28), Vector3(-4.21, 0.10, 0.88), 14.0, "res://textures/tex_cardboard.png", true)
	_carton(ic, "Floor_Fragile2", Vector3(0.36, 0.26, 0.30), Vector3(-4.51, 0.13, 5.40), -8.0, "res://textures/tex_cardboard_fragile.png", true)


func _vent_cover(br: Node) -> void:
	var metal := _sheet_metal()
	var cover := Node3D.new()
	cover.name = "VentCover"
	# Leans on the kitchen west wall, south of the empty opening. Cover is off.
	cover.position = Vector3(0.40, 0.0, 2.08)
	cover.rotation_degrees = Vector3(0, 8, 18)
	br.add_child(cover)
	_box(cover, "Rail_L", Vector3(0.028, 0.90, 0.040), Vector3(0, 0.45, -0.38), metal, Vector3.ZERO, false)
	_box(cover, "Rail_R", Vector3(0.028, 0.90, 0.040), Vector3(0, 0.45, 0.38), metal, Vector3.ZERO, false)
	_box(cover, "Rail_T", Vector3(0.028, 0.040, 0.80), Vector3(0, 0.88, 0), metal, Vector3.ZERO, false)
	_box(cover, "Rail_B", Vector3(0.028, 0.040, 0.80), Vector3(0, 0.04, 0), metal, Vector3.ZERO, false)
	for i in 7:
		_box(cover, "Slat_%d" % i, Vector3(0.016, 0.018, 0.72), Vector3(0, 0.14 + i * 0.10, 0), metal, Vector3.ZERO, false)
	# Empty screw holes on the kitchen flange — cover was unscrewed.
	var dark := _tex_mat("", Color(0.08, 0.08, 0.09), 0.7, 0.4)
	var holes := [
		Vector3(0.165, 0.92, 2.78), Vector3(0.165, 0.92, 3.62),
		Vector3(0.165, 0.12, 2.78), Vector3(0.165, 0.12, 3.62),
	]
	for hi in holes.size():
		_box(br, "VentScrewHole_%d" % hi, Vector3(0.018, 0.018, 0.018), holes[hi], dark, Vector3.ZERO, false)


func _bathroom(level: Node3D) -> void:
	var bath := _find(level, "FutureAssetSlots/Bathroom")
	if bath == null:
		return
	var porcelain := _tex_mat("res://textures/tex_porcelain.png", Color(0.90, 0.90, 0.88), 0.18, 0.04)
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var wood := _mat("res://materials/mat_wood.tres")
	# Toilets in the four stalls (west run). toiletbowl.glb is ~1.90 m tall — scale to a real bowl.
	var tz := [7.95, 9.10, 10.25, 11.40]
	for i in tz.size():
		_toilet(bath, "Toilet_%d" % (i + 1), Vector3(-5.35, 0.0, tz[i]), porcelain, metal)
	# Urinal bank on the BACK (north) wall, east of the stall run — not on stall-door partitions.
	var ux := [-0.50, 0.50, 1.50]
	for i in ux.size():
		_toilet(bath, "Urinal_%d" % i, Vector3(ux[i], 0.0, 12.82), porcelain, metal, 180.0)
	# Real privacy screens: taller + deeper than the old 0.95 × 0.42 slabs.
	_box(bath, "UrinalDivider_0", Vector3(0.05, 1.48, 0.74), Vector3(0.00, 1.08, 12.70), porcelain)
	_box(bath, "UrinalDivider_1", Vector3(0.05, 1.48, 0.74), Vector3(1.00, 1.08, 12.70), porcelain)
	# Vanity along the south wall. Mesh AABB 1.90 × 0.85 × 0.42. Scale X to the 2.85 m mirror.
	var vanity := _instance_glb(bath, "res://models/bathroom_vanity.glb", "BathroomVanity", Vector3(0.15, 0.427, 6.81), Vector3(0, 0, 0), Vector3(1.50, 1.00, 1.00))
	_box_collision(vanity, Vector3(2.85, 0.84, 0.40), Vector3(0.0, 0.0, 0.0))
	_box(bath, "Soap", Vector3(0.08, 0.12, 0.06), Vector3(-0.2, 0.92, 6.90), _tex_mat("res://textures/tex_porcelain.png", Color(0.7, 0.75, 0.6)), Vector3.ZERO, false)
	# Silver glass + wood frame. Compat has no IBL — skip the dark metal texture,
	# keep metallic at the QA floor, and emit enough silver that the pane cannot crush to black.
	var silver := _tex_mat("", Color(0.74, 0.78, 0.84), 0.38, 0.55, 0.40)
	silver.metallic_specular = 0.30
	silver.emission = Color(0.58, 0.62, 0.70)
	_box(bath, "MirrorWide", Vector3(2.85, 1.15, 0.018), Vector3(0.15, 1.72, 6.695), silver, Vector3.ZERO, false)
	var frame := _mat("res://materials/mat_walnut.tres")
	if frame == null:
		frame = wood
	_box(bath, "MirrorFrame_T", Vector3(3.02, 0.07, 0.045), Vector3(0.15, 2.325, 6.688), frame, Vector3.ZERO, false)
	_box(bath, "MirrorFrame_B", Vector3(3.02, 0.07, 0.045), Vector3(0.15, 1.115, 6.688), frame, Vector3.ZERO, false)
	_box(bath, "MirrorFrame_L", Vector3(0.07, 1.28, 0.045), Vector3(-1.340, 1.72, 6.688), frame, Vector3.ZERO, false)
	_box(bath, "MirrorFrame_R", Vector3(0.07, 1.28, 0.045), Vector3(1.640, 1.72, 6.688), frame, Vector3.ZERO, false)
	var crack := _tex_mat("", Color(0.22, 0.24, 0.26, 0.78), 0.55, 0.35)
	crack.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_box(bath, "MirrorCrack_0", Vector3(0.010, 1.02, 0.008), Vector3(-0.55, 1.70, 6.708), crack, Vector3(0, 0, 18), false)
	_box(bath, "MirrorCrack_1", Vector3(0.86, 0.010, 0.008), Vector3(0.40, 1.95, 6.708), crack, Vector3(0, 0, -22), false)
	_box(bath, "MirrorCrack_2", Vector3(0.010, 0.68, 0.008), Vector3(1.05, 1.55, 6.708), crack, Vector3(0, 0, -12), false)
	# Stall doors hinged on the partitions, not floating mid-gap
	var hinge_z := [7.40, 8.55, 9.70, 10.85]
	for i in hinge_z.size():
		var hinge := Node3D.new()
		hinge.name = "StallDoorHinge_%d" % (i + 1)
		hinge.position = Vector3(-3.50, 0.0, hinge_z[i] + 0.03)
		hinge.rotation_degrees = Vector3(0, 28 + i * 4, 0)
		bath.add_child(hinge)
		_box(hinge, "Slab", Vector3(0.04, 1.86, 0.92), Vector3(0.0, 1.00, 0.48), wood)
	# WOMEN on locked supply slab. The bathroom hall door that stuck into the aisle is gone.
	var women := _tex_mat("res://textures/decal_women.png", Color.WHITE, 0.5)
	women.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_quad(level, "WomenDecal", Vector2(0.28, 0.28), Vector3(4.88, 1.55, 8.50), Vector3(0, 90, 0), women)


func _oak_mat() -> StandardMaterial3D:
	var oak := _tex_mat("res://textures/hero/tex-light-oak.png", Color(0.98, 0.90, 0.72), 0.38)
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
	# Parent yaw 180. Mesh was +90; flip 180 → −90 so the sit-side faces the lobby.
	# Chair stays on the sit side after the flip. Counter height 0.86 m.
	var desk := Node3D.new()
	desk.name = "ReceptionDesk2"
	desk.position = Vector3(24.55, 0.0, 11.50)
	desk.rotation_degrees = Vector3(0, 180, 0)
	rec.add_child(desk)
	# load() only — do not exists-gate. Soft-fail to the oak CSG desk.
	var packed: PackedScene = load("res://models/reception_desk.glb")
	var used_glb := false
	if packed:
		var inst := packed.instantiate() as Node3D
		if inst:
			used_glb = true
			inst.name = "ReceptionDeskMesh"
			# Mesh AABB y −0.665..0.667. Sit on the floor; high back stays in the GLB.
			inst.position = Vector3(0.0, 0.665, 0.0)
			inst.rotation_degrees = Vector3(0, -90, 0)
			desk.add_child(inst)
			var body := _box(desk, "ReceptionDesk", Vector3(1.16, 0.82, 1.88), Vector3(0.0, 0.41, 0.0), oak)
			body.visible = false
			var top := _box(desk, "ReceptionDeskTop", Vector3(1.24, 0.04, 1.88), Vector3(0.0, 0.84, 0.0), oak)
			top.visible = false
	if not used_glb:
		_box(desk, "ReceptionDesk", Vector3(1.10, 0.82, 2.55), Vector3(0.0, 0.41, 0.0), oak)
		_box(desk, "ReceptionDeskTop", Vector3(1.24, 0.04, 2.70), Vector3(0.0, 0.84, 0.0), oak)
		# Raised visitor ledge — player's left (world +Z = local −Z).
		_box(desk, "VisitorLedge", Vector3(0.30, 0.10, 1.15), Vector3(0.46, 0.91, -0.62), oak)
		_box(desk, "ReceptionDrawer", Vector3(0.02, 0.10, 0.36), Vector3(0.56, 0.46, 0.85), dark, Vector3.ZERO, false)
		_box(desk, "ReceptionDrawer_02", Vector3(0.02, 0.10, 0.36), Vector3(0.56, 0.46, -0.85), dark, Vector3.ZERO, false)
	# Monitor / keyboard / papers face the sit-side (local +X = world west / lobby).
	_box(desk, "ReceptionMonitor", Vector3(0.07, 0.28, 0.42), Vector3(0.36, 1.04, 0.16), metal)
	_box(desk, "ReceptionMonitorStand", Vector3(0.08, 0.10, 0.10), Vector3(0.30, 0.89, 0.16), metal, Vector3.ZERO, false)
	var screen := _tex_mat("res://textures/tv_snow.png", Color(0.08, 0.10, 0.12), 0.35, 0.0, 0.12)
	_quad(desk, "ReceptionScreen", Vector2(0.40, 0.24), Vector3(0.405, 1.05, 0.16), Vector3(0, 90, 0), screen)
	_box(desk, "ReceptionKeyboard", Vector3(0.14, 0.02, 0.32), Vector3(0.18, 0.87, 0.16), metal, Vector3.ZERO, false)
	_box(desk, "ReceptionPapers", Vector3(0.18, 0.01, 0.24), Vector3(0.16, 0.87, -0.55), paper, Vector3(0, 16, 0), false)
	_box(desk, "Stapler", Vector3(0.08, 0.035, 0.03), Vector3(-0.10, 0.88, 0.72), metal, Vector3.ZERO, false)
	_box(desk, "Tape", Vector3(0.07, 0.05, 0.07), Vector3(-0.14, 0.885, -0.88), metal, Vector3.ZERO, false)
	# Chair on the sit side after the 180 flip (local +X = world west / lobby).
	_box(desk, "LeatherSeat", Vector3(0.44, 0.06, 0.42), Vector3(0.78, 0.46, 0.0), leather, Vector3.ZERO, false)
	_box(desk, "LeatherBack", Vector3(0.07, 0.78, 0.44), Vector3(0.96, 0.92, 0.0), leather, Vector3.ZERO, false)
	_box(desk, "LeatherArm_L", Vector3(0.28, 0.14, 0.06), Vector3(0.78, 0.58, 0.20), leather, Vector3.ZERO, false)
	_box(desk, "LeatherArm_R", Vector3(0.28, 0.14, 0.06), Vector3(0.78, 0.58, -0.20), leather, Vector3.ZERO, false)
	# Dark walnut panels on the divider west face, then the AURUM plate.
	var panel := _tex_mat("res://textures/tex_walnut.png", Color(0.24, 0.14, 0.08), 0.50)
	panel.uv1_triplanar = true
	panel.uv1_world_triplanar = true
	panel.uv1_scale = Vector3(0.35, 2.2, 0.35)
	for i in 5:
		var z := 9.55 + i * 0.98
		_box(rec, "WalnutPanel_%d" % i, Vector3(0.018, 2.72, 0.92), Vector3(25.888, 1.50, z), panel, Vector3.ZERO, false)
	var plate := _tex_mat("res://textures/hero/aurum-logo.png", Color.WHITE, 0.55)
	plate.metallic = 0.04
	plate.roughness = 0.55
	plate.emission_enabled = true
	plate.emission = Color(1.0, 0.96, 0.88)
	plate.emission_energy_multiplier = 0.42
	# West-facing quad in front of the walnut so the logo actually reads from the lobby.
	_quad(rec, "AurumPlate", Vector2(1.72, 1.08), Vector3(25.82, 1.88, 11.50), Vector3(0, -90, 0), plate)


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
	# Fallen door stood as wreckage at the bathroom opening (south jamb). Hall stays walkable.
	var fallen := Node3D.new()
	fallen.name = "FallenDoor"
	fallen.position = Vector3(1.74, 0.0, 8.46)
	fallen.rotation_degrees = Vector3(0, 6, 0)
	root.add_child(fallen)
	_box(fallen, "Slab", Vector3(0.08, 1.86, 0.90), Vector3(0.02, 0.72, 0.10), wood, Vector3(12, 0, -18))
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
		_dress_alcoves(hall)


func _dress_alcoves(hall: Node) -> void:
	# Cubicle stub (south) + copy/mail alcove (north). Real office junk, not empty grey.
	# Keep the east cubicle chase lane (X ≳ 9.9, Z 8.2–10.2) clear.
	var wood := _mat("res://materials/mat_wood.tres")
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var paper := _mat("res://materials/mat_paper.tres")
	var plant := _mat("res://materials/mat_plant.tres")
	var leather := _mat("res://materials/mat_leather.tres")
	# Cubicle — west bay around the desk.
	_box(hall, "CubicleFileCab", Vector3(0.42, 1.12, 0.56), Vector3(7.78, 0.56, 9.55), metal)
	_box(hall, "CubicleFileDrawer_0", Vector3(0.38, 0.18, 0.04), Vector3(7.78, 0.78, 9.84), metal, Vector3.ZERO, false)
	_box(hall, "CubicleFileDrawer_1", Vector3(0.38, 0.18, 0.04), Vector3(7.78, 0.52, 9.84), metal, Vector3.ZERO, false)
	_box(hall, "CubicleInbox", Vector3(0.28, 0.04, 0.22), Vector3(8.42, 0.80, 8.22), paper, Vector3(0, -12, 0), false)
	_box(hall, "CubiclePapers", Vector3(0.22, 0.01, 0.16), Vector3(7.72, 0.79, 8.22), paper, Vector3(0, 18, 0), false)
	_box(hall, "CubicleMug", Vector3(0.07, 0.09, 0.07), Vector3(8.38, 0.82, 8.52), _tex_mat("res://textures/tex_porcelain.png", Color(0.55, 0.22, 0.16)), Vector3.ZERO, false)
	_box(hall, "CubicleLampBase", Vector3(0.08, 0.22, 0.08), Vector3(7.68, 0.90, 8.48), metal, Vector3.ZERO, false)
	_box(hall, "CubicleLampArm", Vector3(0.28, 0.03, 0.03), Vector3(7.82, 1.02, 8.48), metal, Vector3.ZERO, false)
	_box(hall, "CubicleLampHead", Vector3(0.12, 0.06, 0.10), Vector3(7.98, 1.00, 8.48), metal, Vector3.ZERO, false)
	_box(hall, "CubicleBinders", Vector3(0.26, 0.20, 0.08), Vector3(7.78, 1.22, 9.55), _tex_mat("", Color(0.18, 0.28, 0.42)), Vector3.ZERO, false)
	_box(hall, "CubiclePlantPot", Vector3(0.16, 0.14, 0.16), Vector3(7.78, 0.08, 8.85), wood, Vector3.ZERO, false)
	_box(hall, "CubiclePlant", Vector3(0.22, 0.28, 0.18), Vector3(7.78, 0.28, 8.85), plant, Vector3.ZERO, false)
	_box(hall, "CubicleCoatHook", Vector3(0.04, 0.08, 0.04), Vector3(7.62, 1.55, 9.95), metal, Vector3.ZERO, false)
	_box(hall, "CubicleCoat", Vector3(0.08, 0.72, 0.28), Vector3(7.70, 1.12, 9.95), leather, Vector3.ZERO, false)
	# Copy / mail alcove — around the copier, table, and slot bank.
	_box(hall, "CopyWaterCooler", Vector3(0.36, 1.05, 0.36), Vector3(7.82, 0.53, 14.05), metal)
	_box(hall, "CopyWaterJug", Vector3(0.28, 0.32, 0.28), Vector3(7.82, 1.22, 14.05), _tex_mat("res://textures/tex_porcelain.png", Color(0.75, 0.82, 0.88, 0.72), 0.12), Vector3.ZERO, false)
	_box(hall, "CopyTrash", Vector3(0.28, 0.42, 0.28), Vector3(7.82, 0.22, 15.85), _tex_mat("res://textures/tex_metal.png", Color(0.22, 0.22, 0.20)), Vector3.ZERO, false)
	_box(hall, "CopyClipboard", Vector3(0.22, 0.02, 0.30), Vector3(10.72, 0.82, 14.12), paper, Vector3(0, -8, 0), false)
	_box(hall, "CopyStapler", Vector3(0.08, 0.04, 0.03), Vector3(10.88, 0.83, 13.92), metal, Vector3.ZERO, false)
	_carton(hall, "CopyToner_0", Vector3(0.28, 0.18, 0.22), Vector3(9.15, 0.10, 15.75), 12.0, "res://textures/tex_cardboard.png", false)
	_carton(hall, "CopyToner_1", Vector3(0.30, 0.16, 0.24), Vector3(9.48, 0.09, 15.55), -18.0, "res://textures/tex_cardboard_copy.png", false)
	_carton(hall, "CopyMailCrate", Vector3(0.42, 0.22, 0.32), Vector3(11.55, 0.12, 14.15), 8.0, "res://textures/tex_cardboard_tape.png", false)
	_box(hall, "CopyReam_0", Vector3(0.22, 0.06, 0.28), Vector3(10.55, 0.84, 13.88), paper, Vector3(0, 6, 0), false)
	_box(hall, "CopyReam_1", Vector3(0.22, 0.06, 0.28), Vector3(10.55, 0.90, 13.88), paper, Vector3(0, -4, 0), false)
	_box(hall, "CopyEnvelopes", Vector3(0.18, 0.04, 0.24), Vector3(10.90, 1.95, 16.02), paper, Vector3.ZERO, false)


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
	# Framed art — Front Range / Denver. No diplomas.
	var paint := _tex_mat("res://textures/painting_mountains.png")
	var denver := _tex_mat("res://textures/painting_denver_city.png")
	_box(ceo, "FrameMountain", Vector3(1.15, 0.8, 0.04), Vector3(32.2, 1.75, 6.62), wood, Vector3.ZERO, false)
	_quad(ceo, "PaintingMountain", Vector2(1.05, 0.7), Vector3(32.2, 1.75, 6.65), Vector3.ZERO, paint)
	_box(ceo, "FramePlant", Vector3(0.70, 0.88, 0.04), Vector3(35.15, 1.70, 6.62), wood, Vector3.ZERO, false)
	_quad(ceo, "PaintingPlant", Vector2(0.62, 0.78), Vector3(35.15, 1.70, 6.65), Vector3.ZERO, denver)
	_box(ceo, "FrameWest", Vector3(0.55, 0.7, 0.04), Vector3(27.2, 1.7, 14.2), wood, Vector3(0, 90, 0), false)
	_quad(ceo, "PaintingWest", Vector2(0.48, 0.62), Vector3(27.23, 1.7, 14.2), Vector3(0, 90, 0), paint)
	# Dead executive — mid-office, visible from the south door, window ahead.
	_build_ceo_body(ceo)


func _build_ceo_body(ceo: Node) -> void:
	# Locked: X=0 is supine (chest/face up). X=180 was prone. Do not change Y.
	var body := Node3D.new()
	body.name = "DeadExecutive"
	body.position = Vector3(32.05, 0.27, 11.45)
	body.rotation_degrees = Vector3(0, 18, 0)
	body.scale = Vector3.ONE
	ceo.add_child(body)
	# Rug stays on the floor (not pitched with the body).
	var rug_a := _tex_mat("res://textures/tex_leather.png", Color(0.42, 0.30, 0.20), 0.85)
	var rug_b := _tex_mat("res://textures/tex_leather.png", Color(0.62, 0.50, 0.36), 0.85)
	var rug_c := _tex_mat("res://textures/tex_stone.png", Color(0.28, 0.28, 0.30), 0.80)
	_box(ceo, "CeoRug_A", Vector3(2.10, 0.006, 0.36), Vector3(32.05, 0.004, 11.10), rug_a, Vector3(0, 18, 0), false)
	_box(ceo, "CeoRug_B", Vector3(2.10, 0.006, 0.36), Vector3(32.05, 0.004, 11.45), rug_b, Vector3(0, 18, 0), false)
	_box(ceo, "CeoRug_C", Vector3(2.10, 0.006, 0.36), Vector3(32.05, 0.004, 11.80), rug_c, Vector3(0, 18, 0), false)
	_build_ceo_blood(ceo)
	# load() only — do not exists-gate. ceo_dead2 replaces ceo_dead at the locked pose/spot.
	var packed: PackedScene = load("res://models/ceo_dead2.glb")
	if packed:
		var inst := packed.instantiate() as Node3D
		if inst:
			inst.name = "CeoDeadMesh"
			# Mesh AABB y −0.152..0.141, length along X. Authored face-down.
			# Parent Y=0.27 / rot X=0 is locked. Yaw 90 follows the old +Z body.
			# Do not X-rotate 180 — that put him on his back.
			inst.position = Vector3(0.0, -0.129, 0.0)
			inst.rotation_degrees = Vector3(0, 90, 0)
			inst.scale = Vector3.ONE
			body.add_child(inst)
			return
	# Soft-fail: face toward local +Y, length along +Z. Parent X=0 is supine.
	# Origin is the torso, so Y=0.27 seats it.
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


func _build_ceo_blood(ceo: Node) -> void:
	# Founder rejected the seven blotches / smear-spray / pool light. Mesh only.
	for gone in ["CeoBloodPool", "BodyPoolLight", "BodyBlood", "BodyBlood_A", "BodyBlood_B"]:
		var old := ceo.get_node_or_null(gone)
		if old:
			old.free()
	for i in range(1, 8):
		var blot := ceo.get_node_or_null("BodyBlood_%d" % i)
		if blot:
			blot.free()
	# load() only — do not exists-gate. Soft-fail if the GLB is not packed yet.
	var packed: PackedScene = load("res://models/blood_pool.glb")
	if packed == null:
		return
	var inst := packed.instantiate() as Node3D
	if inst == null:
		return
	inst.name = "BloodPool"
	# Flat pool (~1.9 x 1.8 m, ~2 cm thick) on the floor under the supine CEO.
	# CEO stays at (32.05, 0.27, 11.45), rotation (0, 18, 0). Do not move him.
	inst.position = Vector3(32.05, 0.016, 11.45)
	inst.rotation_degrees = Vector3(0, 18, 0)
	ceo.add_child(inst)


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


func _toilet(parent: Node, name: String, pos: Vector3, porcelain: Material, metal: Material, yaw: float = 0.0) -> void:
	var root := Node3D.new()
	root.name = name
	root.position = pos
	root.rotation_degrees = Vector3(0, yaw, 0)
	parent.add_child(root)
	# load() only. Mesh is ~1.90 m tall; 0.40 scale is a real bowl (~0.76 m).
	var bowl := _instance_glb(root, "res://models/toiletbowl.glb", "ToiletBowl", Vector3(0.0, 0.380, 0.0), Vector3.ZERO, Vector3(0.40, 0.40, 0.40))
	_box_collision(root, Vector3(0.64, 0.74, 0.66), Vector3(0.0, 0.38, 0.0))
	if bowl.get_child_count() == 0:
		_box(root, "Tank", Vector3(0.38, 0.42, 0.16), Vector3(-0.14, 0.62, 0.0), porcelain)
		_box(root, "Bowl", Vector3(0.36, 0.34, 0.48), Vector3(0.10, 0.22, 0.0), porcelain)
		_box(root, "Seat", Vector3(0.34, 0.04, 0.42), Vector3(0.10, 0.40, 0.0), porcelain, Vector3.ZERO, false)
		_box(root, "Lid", Vector3(0.34, 0.36, 0.04), Vector3(-0.12, 0.62, 0.0), porcelain, Vector3.ZERO, false)
		_box(root, "Flush", Vector3(0.06, 0.04, 0.08), Vector3(-0.14, 0.86, 0.0), metal, Vector3.ZERO, false)


func _locked_doors(level: Node3D) -> void:
	# Elevator GLB replaces the existing elevator door (north-hall east / supply opening).
	# closed_door.glb stays on the conference hall lock. ChaosDoor is not swapped.
	_swap_elevator(_find(level, "FutureAssetSlots/SupplyCloset/LockedDoor_Supply"))
	_swap_locked_door(_find(level, "FutureAssetSlots/EastHall/LockedDoor_DeadOffice"), 0.0)


func _swap_elevator(door: Node) -> void:
	if door == null:
		return
	_hide_visual(door.get_node_or_null("Slab"))
	_hide_visual(door.get_node_or_null("Handle"))
	# Mesh AABB y −0.952..0.951, 1.16 × 1.90 × 0.18. Seat on the floor in the frame.
	_instance_glb(door, "res://models/closed_elevator.glb", "ClosedElevator", Vector3(0.0, 0.952, 0.0), Vector3(0, 90, 0), Vector3.ONE)


func _swap_locked_door(door: Node, yaw: float) -> void:
	if door == null:
		return
	_hide_visual(door.get_node_or_null("Slab"))
	_hide_visual(door.get_node_or_null("Handle"))
	# Mesh AABB y −0.953..0.951, 0.88 × 1.90 × 0.15. Seat on the floor inside the frame.
	_instance_glb(door, "res://models/closed_door.glb", "ClosedDoor", Vector3(0.0, 0.952, 0.0), Vector3(0, yaw, 0), Vector3.ONE)


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
	# Break room — skip the vent on the shared west wall (Z 2.72–3.68)
	_trim_span(root, i, true, 0.20, 6.80, 0.12, [], trim)
	_trim_span(root, i, false, 0.20, 6.40, 0.12, [[2.72, 3.68]], trim)
	_trim_span(root, i, false, 0.20, 6.40, 6.88, [], trim)
	# Intro closet — skip chaos door and the closet-side duct mouth
	_trim_span(root, i, true, -9.46, -2.88, 0.12, [], trim)
	_trim_span(root, i, true, -9.46, -2.88, 6.34, [], trim)
	_trim_span(root, i, false, 0.20, 6.30, -9.58, [[2.70, 3.80]], trim)
	_trim_span(root, i, false, 0.20, 6.30, -2.78, [[2.72, 3.68]], trim)
	# L-shaped hallway walls stay flat — no baseboard / chair-rail nubs in the walk path.
	# CEO side of the divider only (reception / logo face stays flush).
	_trim_span(root, i, false, 8.53, 14.48, 26.14, [], trim)
	# CEO south / north — skip nothing on the long walls
	_trim_span(root, i, true, 26.20, 37.80, 6.62, [], trim)
	_trim_span(root, i, true, 26.20, 37.80, 16.38, [], trim)
	var scuffs := [
		[Vector3(3.40, 0.22, 0.14), Vector2(1.50, 0.30), Vector3(0, 0, 0)],
		[Vector3(5.80, 0.20, 0.14), Vector2(0.90, 0.22), Vector3(0, 0, 0)],
		[Vector3(0.14, 0.24, 2.40), Vector2(1.10, 0.26), Vector3(0, 90, 0)],
		[Vector3(8.90, 0.24, 10.54), Vector2(1.20, 0.28), Vector3(0, 0, 0)],
		[Vector3(13.20, 0.22, 10.54), Vector2(1.00, 0.24), Vector3(0, 0, 0)],
		[Vector3(16.60, 0.22, 13.46), Vector2(1.30, 0.26), Vector3(0, 180, 0)],
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
	var front_range := _tex_mat("res://textures/painting_front_range.png")
	var denver := _tex_mat("res://textures/painting_denver_city.png")
	var city := _tex_mat("res://textures/painting_map.png")
	# Left wall walking east toward Ember / AURUM (north face Z≈13.4). Spaced, no diplomas.
	_frame(root, "HallFrontRange", Vector3(13.70, 1.70, 13.36), Vector2(1.08, 0.70), Vector3(0, 180, 0), wood, front_range)
	_frame(root, "HallDenver", Vector3(18.15, 1.68, 13.36), Vector2(1.00, 0.66), Vector3(0, 180, 0), wood, denver)
	# South wall of that stretch — one map, well clear of the north-wall pair.
	_frame(root, "HallMap", Vector3(14.10, 1.68, 10.56), Vector2(0.88, 0.62), Vector3(0, 0, 0), wood, city)
	_frame(root, "ReceptionMap", Vector3(20.20, 1.72, 16.36), Vector2(0.95, 0.66), Vector3(0, 180, 0), wood, city)
	_frame(root, "ReceptionDenver", Vector3(23.55, 1.70, 16.36), Vector2(0.92, 0.62), Vector3(0, 180, 0), wood, denver)
	_frame(root, "ReceptionMountains", Vector3(21.80, 1.70, 6.64), Vector2(1.02, 0.68), Vector3(0, 0, 0), wood, mountains)
	_frame(root, "DividerFrontRange", Vector3(26.16, 1.70, 10.05), Vector2(0.86, 0.60), Vector3(0, 90, 0), wood, front_range)
	_frame(root, "DividerMap", Vector3(26.16, 1.72, 12.70), Vector2(0.80, 0.58), Vector3(0, 90, 0), wood, city)
	_frame(root, "CEONorthMap", Vector3(30.20, 1.72, 16.36), Vector2(0.90, 0.64), Vector3(0, 180, 0), wood, city)
	_frame(root, "CEONorthDenver", Vector3(33.40, 1.70, 16.36), Vector2(0.88, 0.60), Vector3(0, 180, 0), wood, denver)
	_frame(root, "BreakFrontRange", Vector3(0.14, 1.58, 4.20), Vector2(0.72, 0.50), Vector3(0, 90, 0), wood, front_range)
	_frame(root, "BreakMap", Vector3(6.86, 1.62, 4.80), Vector2(0.70, 0.50), Vector3(0, -90, 0), wood, city)


func _frame(parent: Node, name: String, pos: Vector3, size: Vector2, rot: Vector3, wood: Material, art: Material) -> void:
	_box(parent, name + "Frame", Vector3(size.x + 0.08, size.y + 0.08, 0.035), pos, wood, rot, false)
	var face := pos
	if abs(rot.y) < 1.0:
		face.z += 0.038
	elif abs(rot.y - 180.0) < 1.0:
		face.z -= 0.038
	elif abs(rot.y - 90.0) < 1.0:
		face.x += 0.038
	elif abs(rot.y + 90.0) < 1.0:
		face.x -= 0.038
	_quad(parent, name + "Art", size, face, rot, art)


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


func _seat_on_floor(n: Node3D) -> void:
	var acc := [true, AABB()]
	_accum_aabb(n, acc)
	if acc[0]:
		return
	var a: AABB = acc[1]
	n.global_position.y -= a.position.y


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


func _fix_floors(level: Node3D) -> void:
	# Bathroom stone used to overlap hall carpet at the doorway (black band / flicker).
	var bath := _find(level, "Architecture/Floors/BathroomFloor") as CSGBox3D
	if bath:
		var west := bath.position.x - bath.size.x * 0.5
		# Meet the hall carpet at X=2.00 — a 6 cm gap read as a black band.
		bath.size.x = 2.00 - west
		bath.position.x = (west + 2.00) * 0.5
		# Light porcelain so the opening does not read as a void against the taupe carpet.
		var tile := _tex_mat("res://textures/tex_porcelain.png", Color(0.88, 0.88, 0.86), 0.38, 0.02)
		tile.uv1_triplanar = true
		tile.uv1_world_triplanar = true
		tile.uv1_scale = Vector3(0.55, 0.55, 0.55)
		_set_csg_mat(bath, tile)
	var nh := _find(level, "Architecture/Floors/NorthHallFloor") as CSGBox3D
	if nh:
		# X 2.00–5.00 (3.0 m), Z 6.52–10.50. No overlap with bathroom or corner.
		nh.position = Vector3(3.50, -0.1000, 8.51)
		nh.size = Vector3(3.00, 0.2000, 3.98)
	var cf := _find(level, "Architecture/Floors/CornerFloor") as CSGBox3D
	if cf:
		cf.position = Vector3(3.50, -0.1000, 12.00)
		cf.size = Vector3(3.00, 0.2000, 3.00)
	var eh := _find(level, "Architecture/Floors/EastHallFloor") as CSGBox3D
	if eh:
		# Meet the corner at X=5.00. Z span stays 3.0 m.
		eh.position = Vector3(11.50, -0.1000, 12.00)
		eh.size = Vector3(13.00, 0.2000, 3.00)
	var carpet := _office_carpet()
	# Carpet doormat in the 1.2 m opening. Covers the hall/bath edge and the wall-foot z-fight.
	_box(level, "BathDoorThreshold", Vector3(0.62, 0.036, 1.28), Vector3(1.92, 0.019, 9.00), carpet)
	var sf := _find(level, "Architecture/Floors/SupplyClosetFloor") as CSGBox3D
	if sf:
		var se := sf.position.x + sf.size.x * 0.5
		sf.size.x = se - 5.08
		sf.position.x = (5.08 + se) * 0.5
		_set_csg_mat(sf, carpet)


func _flush_hall(level: Node3D) -> void:
	# Bathroom long walls were 8.66 m and stabbed 0.58 m into the 3 m hall.
	for p in ["Architecture/Walls/BathroomSouth", "Architecture/Walls/BathroomNorth"]:
		var w := _find(level, p) as CSGBox3D
		if w:
			var west := w.position.x - w.size.x * 0.5
			w.size.x = 1.92 - west
			w.position.x = (west + 1.92) * 0.5
	# Conference door + glass sat at Z=11.0 (0.5 m into the east-hall lane).
	var door := _find(level, "FutureAssetSlots/EastHall/LockedDoor_DeadOffice") as Node3D
	if door:
		door.position.z = 10.50
	for gp in ["DeadOfficeGlass", "DeadOfficeGlassMullion", "DeadOfficeGlassMullion_02", "DeadOfficeGlassMullion_03", "DeadOfficeGlassSill"]:
		var g := _find(level, "FutureAssetSlots/EastHall/%s" % gp) as Node3D
		if g:
			g.position.z = 10.50


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
