extends RefCounted
## Runtime set-dressing: textured parted furniture, dread, diorama, props.


func apply(level: Node3D) -> void:
	_texture_existing(level)
	_breakroom(level)
	_bathroom(level)
	_dread(level)
	_ceo(level)
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
	var stone := _tex_mat("res://textures/tex_stone.png", Color(0.22, 0.22, 0.24), 0.2, 0.65)
	for p in [
		"FutureAssetSlots/BreakRoom/KitchenetteCounter",
		"FutureAssetSlots/BreakRoom/KitchenetteCabinets",
		"FutureAssetSlots/BreakRoom/BreakRoomTable",
		"FutureAssetSlots/CEOOffice/LiquorCabinet",
		"FutureAssetSlots/CEOOffice/Bookshelf_01",
		"FutureAssetSlots/CEOOffice/Bookshelf_02",
		"FutureAssetSlots/CEOOffice/Bookshelf_03",
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
	]:
		_set_csg_mat(_find(level, p), leather)
	for p in [
		"FutureAssetSlots/BreakRoom/Fridge",
		"FutureAssetSlots/BreakRoom/Microwave",
		"FutureAssetSlots/BreakRoom/VendingMachine",
		"FutureAssetSlots/EastHall/CubicleDesk",
		"FutureAssetSlots/EastHall/Copier",
		"FutureAssetSlots/Reception/ReceptionDesk",
		"FutureAssetSlots/CEOOffice/CEODesk",
		"FutureAssetSlots/CEOOffice/CEODeskPedestal_L",
		"FutureAssetSlots/CEOOffice/CEODeskPedestal_R",
	]:
		_set_csg_mat(_find(level, p), metal)
	_set_csg_mat(_find(level, "FutureAssetSlots/BreakRoom/FridgeHandle"), wood)
	_set_csg_mat(_find(level, "FutureAssetSlots/EastHall/CubicleMonitor"), _tex_mat("res://textures/tv_snow.png", Color.WHITE, 0.4, 0.0, 0.4))
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/PlantFoliage"), plant)
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/PlantPot"), wood)
	_set_csg_mat(_find(level, "FutureAssetSlots/CEOOffice/CEOBlotter"), leather)
	_set_csg_mat(_find(level, "Architecture/Floors/CEOOfficeFloor"), stone)
	var win := _find(level, "FutureAssetSlots/CEOOffice/MoneyShotWindow")
	if win:
		for n in ["Pane_01", "Pane_02", "Pane_03"]:
			var pane := win.get_node_or_null(n) as CSGBox3D
			if pane:
				pane.material = glass
				pane.visible = true
		var mull := _mat("res://materials/mat_mullion.tres")
		for n in ["Mullion_Left", "Mullion_01", "Mullion_02", "Mullion_Right", "Sill", "Head"]:
			_set_csg_mat(win.get_node_or_null(n), mull)
	var spot2 := _find(level, "DemonSpots/DemonSpot_02")
	if spot2:
		spot2.visible = false


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
	var rec := _find(level, "FutureAssetSlots/Reception")
	if rec:
		_box(rec, "ReceptionMonitor", Vector3(0.42, 0.3, 0.06), Vector3(23.7, 1.32, 11.15), metal)
		_box(rec, "ReceptionKeyboard", Vector3(0.32, 0.02, 0.12), Vector3(23.55, 1.11, 11.55), metal, Vector3.ZERO, false)
		_box(rec, "ReceptionDrawer", Vector3(0.4, 0.12, 0.02), Vector3(23.9, 0.55, 10.1), wood, Vector3.ZERO, false)
	# Table papers
	_box(br, "TablePapers", Vector3(0.28, 0.01, 0.2), Vector3(3.7, 0.77, 3.55), paper, Vector3(0, 18, 0), false)
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
	var porcelain := _tex_mat("", Color(0.86, 0.86, 0.84), 0.22, 0.05)
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var wood := _mat("res://materials/mat_wood.tres")
	# Real fixtures: urinal, extra sink faucet, soap
	_box(bath, "Urinal", Vector3(0.36, 0.72, 0.28), Vector3(1.6, 0.85, 12.55), porcelain)
	_box(bath, "UrinalFlush", Vector3(0.08, 0.08, 0.06), Vector3(1.6, 1.28, 12.68), metal, Vector3.ZERO, false)
	_box(bath, "Faucet", Vector3(0.04, 0.12, 0.16), Vector3(0.2, 0.62, 6.78), metal, Vector3.ZERO, false)
	_box(bath, "Faucet_02", Vector3(0.04, 0.12, 0.16), Vector3(1.05, 0.62, 6.78), metal, Vector3.ZERO, false)
	_box(bath, "Soap", Vector3(0.08, 0.12, 0.06), Vector3(-0.2, 1.15, 6.74), _tex_mat("", Color(0.7, 0.75, 0.6)), Vector3.ZERO, false)
	# Ajar MEN door on the north-hall opening
	var door := Node3D.new()
	door.name = "MensDoorAjar"
	door.position = Vector3(2.50, 0.0, 8.42)
	door.rotation_degrees = Vector3(0, 52, 0)
	level.add_child(door)
	_box(door, "Slab", Vector3(0.06, 2.08, 1.16), Vector3(0.0, 1.04, 0.58), wood)
	var men := _tex_mat("res://textures/decal_men.png", Color.WHITE, 0.5)
	men.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_quad(door, "MenDecal", Vector2(0.28, 0.28), Vector3(-0.04, 1.55, 0.58), Vector3(0, -90, 0), men)
	# WOMEN on locked supply slab
	var women := _tex_mat("res://textures/decal_women.png", Color.WHITE, 0.5)
	women.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_quad(level, "WomenDecal", Vector2(0.28, 0.28), Vector3(4.38, 1.55, 8.50), Vector3(0, 90, 0), women)


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


func _ceo(level: Node3D) -> void:
	var ceo := _find(level, "FutureAssetSlots/CEOOffice")
	if ceo == null:
		return
	var leather := _mat("res://materials/mat_leather.tres")
	var wood := _mat("res://materials/mat_wood.tres")
	var metal := _mat("res://materials/mat_metal_furn.tres")
	var paper := _mat("res://materials/mat_paper.tres")
	# Leather chair parts on the existing side chair
	_box(ceo, "LeatherSeat", Vector3(0.52, 0.08, 0.5), Vector3(33.70, 0.52, 10.55), leather, Vector3.ZERO, false)
	_box(ceo, "LeatherBack", Vector3(0.5, 0.7, 0.08), Vector3(33.42, 0.95, 10.55), leather, Vector3.ZERO, false)
	_box(ceo, "LeatherArm_L", Vector3(0.08, 0.22, 0.42), Vector3(33.70, 0.62, 10.28), leather, Vector3.ZERO, false)
	_box(ceo, "LeatherArm_R", Vector3(0.08, 0.22, 0.42), Vector3(33.70, 0.62, 10.82), leather, Vector3.ZERO, false)
	# Desk drawers
	_box(ceo, "DeskDrawer_L", Vector3(0.36, 0.12, 0.02), Vector3(34.55, 0.42, 10.98), wood, Vector3.ZERO, false)
	_box(ceo, "DeskDrawer_R", Vector3(0.36, 0.12, 0.02), Vector3(36.15, 0.42, 10.98), wood, Vector3.ZERO, false)
	# Short bookshelf + fallen books (north wall, off window walk)
	_box(ceo, "ShortShelf", Vector3(1.1, 1.15, 0.3), Vector3(31.4, 0.58, 16.18), wood)
	_box(ceo, "ShortBooks", Vector3(0.9, 0.2, 0.14), Vector3(31.4, 0.85, 16.05), paper, Vector3.ZERO, false)
	_box(ceo, "FallenBook_01", Vector3(0.22, 0.04, 0.16), Vector3(31.9, 0.03, 15.7), paper, Vector3(0, 40, 8), false)
	_box(ceo, "FallenBook_02", Vector3(0.2, 0.04, 0.14), Vector3(31.55, 0.03, 15.45), _tex_mat("", Color(0.25, 0.08, 0.08), 0.7), Vector3(0, -22, 6), false)
	_box(ceo, "FallenBook_03", Vector3(0.18, 0.03, 0.13), Vector3(32.15, 0.025, 15.85), paper, Vector3(0, 70, 4), false)
	# Framed art
	var paint := _tex_mat("res://textures/painting_mountains.png")
	var cert := _tex_mat("res://textures/painting_certificate.png")
	_box(ceo, "FrameMountain", Vector3(1.15, 0.8, 0.04), Vector3(32.2, 1.75, 6.62), wood, Vector3.ZERO, false)
	_quad(ceo, "PaintingMountain", Vector2(1.05, 0.7), Vector3(32.2, 1.75, 6.65), Vector3(0, 180, 0), paint)
	_box(ceo, "FrameCert", Vector3(0.55, 0.7, 0.04), Vector3(27.2, 1.7, 14.2), wood, Vector3(0, 90, 0), false)
	_quad(ceo, "PaintingCert", Vector2(0.48, 0.62), Vector3(27.23, 1.7, 14.2), Vector3(0, 90, 0), cert)
	# Dead executive — north of desk, off the window walk (Z~14.3, X~33.4)
	_dead_exec(ceo)


func _dead_exec(ceo: Node) -> void:
	var body := Node3D.new()
	body.name = "DeadExecutive"
	body.position = Vector3(33.35, 0.02, 14.35)
	body.rotation_degrees = Vector3(0, 18, 0)
	ceo.add_child(body)
	var skin := _tex_mat("", Color(0.62, 0.46, 0.38), 0.55)
	var hair := _tex_mat("", Color(0.12, 0.09, 0.07), 0.8)
	var shirt := _tex_mat("", Color(0.85, 0.86, 0.88), 0.7)
	var tie := _tex_mat("", Color(0.35, 0.05, 0.06), 0.45)
	var suit := _tex_mat("", Color(0.12, 0.13, 0.16), 0.55)
	var shoe := _tex_mat("", Color(0.08, 0.06, 0.05), 0.4)
	# Lying on back, head west, feet east — north of desk so window approach stays clear
	_box(body, "Head", Vector3(0.18, 0.16, 0.2), Vector3(-0.72, 0.12, 0.0), skin, Vector3.ZERO, false)
	_box(body, "Hair", Vector3(0.18, 0.06, 0.2), Vector3(-0.74, 0.20, 0.02), hair, Vector3.ZERO, false)
	_box(body, "Torso", Vector3(0.55, 0.16, 0.38), Vector3(-0.18, 0.12, 0.0), shirt, Vector3.ZERO, false)
	_box(body, "Suit", Vector3(0.58, 0.08, 0.42), Vector3(-0.16, 0.18, 0.0), suit, Vector3.ZERO, false)
	_box(body, "Tie", Vector3(0.28, 0.02, 0.07), Vector3(-0.32, 0.21, 0.0), tie, Vector3.ZERO, false)
	_box(body, "ArmL", Vector3(0.42, 0.08, 0.08), Vector3(-0.1, 0.1, 0.28), shirt, Vector3(0, 20, 12), false)
	_box(body, "ArmR", Vector3(0.38, 0.08, 0.08), Vector3(-0.05, 0.08, -0.26), shirt, Vector3(0, -15, -18), false)
	_box(body, "HandL", Vector3(0.08, 0.04, 0.1), Vector3(0.14, 0.08, 0.38), skin, Vector3.ZERO, false)
	_box(body, "HandR", Vector3(0.08, 0.04, 0.1), Vector3(0.16, 0.06, -0.36), skin, Vector3.ZERO, false)
	_box(body, "LegL", Vector3(0.5, 0.1, 0.12), Vector3(0.42, 0.08, 0.1), suit, Vector3.ZERO, false)
	_box(body, "LegR", Vector3(0.5, 0.1, 0.12), Vector3(0.42, 0.08, -0.1), suit, Vector3.ZERO, false)
	_box(body, "ShoeL", Vector3(0.16, 0.07, 0.1), Vector3(0.72, 0.05, 0.1), shoe, Vector3.ZERO, false)
	_box(body, "ShoeR", Vector3(0.16, 0.07, 0.1), Vector3(0.72, 0.05, -0.1), shoe, Vector3.ZERO, false)


func _diorama(level: Node3D) -> void:
	var dia := Node3D.new()
	dia.name = "ExteriorDiorama"
	dia.position = Vector3(43.5, 0.0, 11.5)
	level.add_child(dia)
	var sky := _tex_mat("res://textures/denver_fire_skyline.png", Color.WHITE, 1.0, 0.0, 2.4)
	sky.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sky.emission_texture = load("res://textures/denver_fire_skyline.png")
	_quad(dia, "Backdrop", Vector2(22.0, 10.0), Vector3(4.0, 3.2, 0.0), Vector3(0, -90, 0), sky)
	# Animated fire / smoke
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
	for i in 5:
		_quad(fire_root, "Fire_%d" % i, Vector2(2.4, 2.8), Vector3(2.2, 0.9 + i * 0.15, -4.0 + i * 2.0), Vector3(0, -90, 0), fire_m)
	for i in 4:
		_quad(fire_root, "Smoke_%d" % i, Vector2(3.2, 3.6), Vector3(2.6, 2.8 + i * 0.4, -3.5 + i * 2.3), Vector3(0, -90, 0), smoke_m)
	# Drifting people silhouettes
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
		_quad(people, "Person_%d" % i, Vector2(0.55 + i * 0.04, 1.35 + (i % 2) * 0.15), Vector3(1.6, 0.85, -5.0 + i * 2.4), Vector3(0, -90, 0), sil_m)


func _ammo(level: Node3D) -> void:
	_spawn_ammo(level, Vector3(3.85, 0.82, 3.55), "Ammo_Break")
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


func _emergency(level: Node3D) -> void:
	var root := Node3D.new()
	root.name = "EmergencyLights"
	root.set_script(load("res://scripts/emergency_lights.gd"))
	level.add_child(root)
	for p in [Vector3(3.5, 2.7, 8.8), Vector3(9.0, 2.7, 12.0), Vector3(15.0, 2.7, 12.0), Vector3(22.0, 2.75, 11.5)]:
		var o := OmniLight3D.new()
		o.light_color = Color(1.0, 0.12, 0.08)
		o.light_energy = 1.6
		o.omni_range = 6.5
		o.shadow_enabled = false
		o.position = p
		root.add_child(o)
