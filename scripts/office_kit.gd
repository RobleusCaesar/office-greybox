extends RefCounted
## Closet + break-room modular kit. Shared meshes, tiled PBR, instanced props.
## TopologyAI method, Godot-web cheapest equivalent: MultiMesh + one box + one bay.
## Pass 1 only. Hall / bath / CEO / elevator stay authored.

const PANEL_W := 1.22
const PANEL_H := 2.74
const TILE := 0.61
const TRIM_W := 1.22
const INSET := 0.014
const FLOOR_Y := 0.003
const CEIL_Y := 2.986
const BAY_W := 1.232

var counts: Dictionary = {
	"wall_panel": 0,
	"trim": 0,
	"floor_tile": 0,
	"ceiling_tile": 0,
	"box": 0,
	"shelf_bay": 0,
	"fixture": 0,
}

var _mesh_panel: QuadMesh
var _mesh_tile: QuadMesh
var _mesh_trim: BoxMesh
var _mesh_box: BoxMesh
var _mesh_upright: BoxMesh
var _mesh_board: BoxMesh
var _mesh_rail: BoxMesh
var _mesh_housing: BoxMesh
var _mesh_diffuser: BoxMesh
var _mesh_strip: BoxMesh

var _mat_wall: Material
var _mat_wall_tri: Material
var _mat_carpet: Material
var _mat_carpet_tri: Material
var _mat_ceil: Material
var _mat_ceil_tri: Material
var _mat_trim: Material
var _mat_box: Material
var _mat_fix: Material
var _mat_metal: Material
var _mat_wood: Material

var _wall_x: Array[Transform3D] = []
var _trim_x: Array[Transform3D] = []
var _floor_x: Array[Transform3D] = []
var _ceil_x: Array[Transform3D] = []


func apply(level: Node3D) -> void:
	_fog_off(level)
	_load_res()
	_skin_existing(level)
	var root := Node3D.new()
	root.name = "OfficeKit"
	level.add_child(root)
	_closet_arch(root)
	_break_arch(root)
	_commit_meshes(root)
	_shelf_runs(level.get_node_or_null("FutureAssetSlots/IntroCloset"))
	_floor_boxes(level.get_node_or_null("FutureAssetSlots/IntroCloset"))
	_fixtures(root, level)
	_retune_lights(level)
	root.set_meta("kit_counts", counts.duplicate())
	print(
		"KIT_COUNTS wall=%s trim=%s floor=%s ceil=%s box=%s bay=%s fixture=%s"
		% [
			counts.wall_panel, counts.trim, counts.floor_tile, counts.ceiling_tile,
			counts.box, counts.shelf_bay, counts.fixture,
		]
	)


func _load_res() -> void:
	_mat_wall = load("res://materials/kit/mat_kit_drywall.tres")
	_mat_wall_tri = load("res://materials/kit/mat_kit_drywall_tri.tres")
	_mat_carpet = load("res://materials/kit/mat_kit_carpet.tres")
	_mat_carpet_tri = load("res://materials/kit/mat_kit_carpet_tri.tres")
	_mat_ceil = load("res://materials/kit/mat_kit_ceiling.tres")
	_mat_ceil_tri = load("res://materials/kit/mat_kit_ceiling_tri.tres")
	_mat_trim = load("res://materials/kit/mat_kit_trim.tres")
	_mat_box = load("res://materials/kit/mat_kit_box.tres")
	_mat_fix = load("res://materials/kit/mat_kit_fixture.tres")
	_mat_metal = load("res://materials/mat_metal_furn.tres")
	_mat_wood = load("res://materials/mat_wood.tres")
	_mesh_panel = QuadMesh.new()
	_mesh_panel.size = Vector2(PANEL_W, PANEL_H)
	_mesh_tile = QuadMesh.new()
	_mesh_tile.size = Vector2(TILE, TILE)
	_mesh_trim = BoxMesh.new()
	_mesh_trim.size = Vector3(TRIM_W, 0.10, 0.038)
	_mesh_box = BoxMesh.new()
	_mesh_box.size = Vector3(0.30, 0.20, 0.24)
	_mesh_upright = BoxMesh.new()
	_mesh_upright.size = Vector3(0.034, 2.80, 0.034)
	_mesh_board = BoxMesh.new()
	_mesh_board.size = Vector3(1.0, 0.028, 0.388)
	_mesh_rail = BoxMesh.new()
	_mesh_rail.size = Vector3(1.0, 0.018, 0.012)
	_mesh_housing = BoxMesh.new()
	_mesh_housing.size = Vector3(1.22, 0.070, 0.34)
	_mesh_diffuser = BoxMesh.new()
	_mesh_diffuser.size = Vector3(1.10, 0.018, 0.24)
	_mesh_strip = BoxMesh.new()
	_mesh_strip.size = Vector3(2.40, 0.018, 0.040)


func _fog_off(level: Node3D) -> void:
	# Office air. Beauty is light + materials, not arena haze.
	var env_n := level.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_n == null or env_n.environment == null:
		return
	var env := env_n.environment
	env.fog_enabled = false
	env.volumetric_fog_enabled = false
	env.fog_density = 0.0
	env.volumetric_fog_density = 0.0


func _skin_existing(level: Node3D) -> void:
	for p in [
		"Architecture/Walls/IntroClosetSouth",
		"Architecture/Walls/IntroClosetNorth",
		"Architecture/Walls/IntroClosetWest",
		"Architecture/Walls/IntroClosetEast",
		"Architecture/Walls/BreakRoomSouth",
		"Architecture/Walls/BreakRoomNorth",
		"Architecture/Walls/BreakRoomWest",
		"Architecture/Walls/BreakRoomEast",
	]:
		_set_mat(level.get_node_or_null(p), _mat_wall_tri)
	for p in [
		"Architecture/Floors/IntroClosetFloor",
		"Architecture/Floors/BreakRoomFloor",
	]:
		_set_mat(level.get_node_or_null(p), _mat_carpet_tri)
	for p in [
		"Architecture/Ceilings/IntroClosetCeiling",
		"Architecture/Ceilings/BreakRoomCeiling",
	]:
		_set_mat(level.get_node_or_null(p), _mat_ceil_tri)


func _set_mat(n: Node, mat: Material) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).material_override = mat
		if (n as MeshInstance3D).mesh is PrimitiveMesh:
			((n as MeshInstance3D).mesh as PrimitiveMesh).material = mat


func _closet_arch(root: Node3D) -> void:
	# Interior faces. Skip vent / chaos door. Header panels over openings.
	_wall_run(Vector3(-9.58, 1.49, 0.094), Vector3.RIGHT, 6.84, Vector3.BACK, [])
	_wall_run(Vector3(-9.58, 1.49, 6.326), Vector3.RIGHT, 6.84, Vector3.FORWARD, [])
	_wall_run(Vector3(-9.566, 1.49, 0.08), Vector3.BACK, 6.26, Vector3.RIGHT, [[2.50, 3.72]])
	_wall_run(Vector3(-2.754, 1.49, 0.08), Vector3.BACK, 6.26, Vector3.LEFT, [[2.64, 3.60]])
	_header(Vector3(-9.566, 2.50, 3.25), Vector3.BACK, 1.22, Vector3.RIGHT, 0.72)
	_header(Vector3(-2.754, 1.98, 3.20), Vector3.BACK, 0.96, Vector3.LEFT, 1.76)
	_tile_rect(-9.58, -2.74, 0.08, 6.34, true)
	_tile_rect(-9.58, -2.74, 0.08, 6.34, false)
	_trim_run(true, -9.46, -2.88, 0.12, [])
	_trim_run(true, -9.46, -2.88, 6.34, [])
	_trim_run(false, 0.20, 6.30, -9.58, [[2.70, 3.80]])
	_trim_run(false, 0.20, 6.30, -2.78, [[2.72, 3.68]])


func _break_arch(root: Node3D) -> void:
	_wall_run(Vector3(0.08, 1.49, 0.094), Vector3.RIGHT, 6.84, Vector3.BACK, [])
	_wall_run(Vector3(0.08, 1.49, 6.406), Vector3.RIGHT, 6.84, Vector3.FORWARD, [[2.90, 4.10]])
	_wall_run(Vector3(0.094, 1.49, 0.08), Vector3.BACK, 6.34, Vector3.RIGHT, [[2.64, 3.60]])
	_wall_run(Vector3(6.906, 1.49, 0.08), Vector3.BACK, 6.34, Vector3.LEFT, [])
	_header(Vector3(3.50, 2.50, 6.406), Vector3.RIGHT, 1.20, Vector3.FORWARD, 0.72)
	_header(Vector3(0.094, 1.98, 3.20), Vector3.BACK, 0.96, Vector3.RIGHT, 1.76)
	_tile_rect(0.08, 6.92, 0.08, 6.42, true)
	_tile_rect(0.08, 6.92, 0.08, 6.42, false)
	_trim_run(true, 0.20, 6.80, 0.12, [])
	_trim_run(false, 0.20, 6.40, 0.12, [[2.72, 3.68]])
	_trim_run(false, 0.20, 6.40, 6.88, [])
	_trim_run(true, 0.20, 6.80, 6.42, [[2.975, 4.025]])


func _wall_run(origin: Vector3, along: Vector3, length: float, inward: Vector3, gaps: Array) -> void:
	along = along.normalized()
	inward = inward.normalized()
	var cursor := 0.0
	var cuts: Array = gaps.duplicate()
	cuts.sort_custom(func(a, b): return a[0] < b[0])
	for g in cuts:
		var lo: float = maxf(0.0, g[0])
		var hi: float = minf(length, g[1])
		if hi <= lo:
			continue
		_wall_fill(origin, along, inward, cursor, lo)
		cursor = maxf(cursor, hi)
	_wall_fill(origin, along, inward, cursor, length)


func _wall_fill(origin: Vector3, along: Vector3, inward: Vector3, a0: float, a1: float) -> void:
	var remain := a1 - a0
	if remain < 0.16:
		return
	var t := a0
	while remain > 0.16:
		var w := minf(PANEL_W, remain)
		if remain > PANEL_W and remain - PANEL_W < 0.28:
			w = remain * 0.5
		var mid := t + w * 0.5
		var pos := origin + along * mid + inward * INSET
		pos.y = 0.12 + PANEL_H * 0.5
		_push_panel(pos, along, inward, w / PANEL_W, 1.0)
		t += w
		remain -= w


func _header(origin: Vector3, along: Vector3, length: float, inward: Vector3, height: float) -> void:
	along = along.normalized()
	inward = inward.normalized()
	var pos := origin + along * (length * 0.5) + inward * INSET
	_push_panel(pos, along, inward, length / PANEL_W, height / PANEL_H)


func _push_panel(pos: Vector3, along: Vector3, inward: Vector3, sx: float, sy: float) -> void:
	var b := Basis.looking_at(-inward, Vector3.UP)
	if absf(sx - 1.0) > 0.002 or absf(sy - 1.0) > 0.002:
		b = b.scaled(Vector3(sx, sy, 1.0))
	_wall_x.append(Transform3D(b, pos))
	counts.wall_panel += 1


func _tile_rect(x0: float, x1: float, z0: float, z1: float, is_floor: bool) -> void:
	var x := x0 + TILE * 0.5
	while x < x1 - 0.04:
		var z := z0 + TILE * 0.5
		while z < z1 - 0.04:
			var y := FLOOR_Y if is_floor else CEIL_Y
			var e := Vector3(-PI * 0.5, 0.0, 0.0) if is_floor else Vector3(PI * 0.5, 0.0, 0.0)
			var t := Transform3D(Basis.from_euler(e), Vector3(x, y, z))
			if is_floor:
				_floor_x.append(t)
				counts.floor_tile += 1
			else:
				_ceil_x.append(t)
				counts.ceiling_tile += 1
			z += TILE
		x += TILE


func _trim_run(along_x: bool, a0: float, a1: float, fixed: float, gaps: Array) -> void:
	var cuts: Array = gaps.duplicate()
	cuts.sort_custom(func(a, b): return a[0] < b[0])
	var cursor := a0
	for g in cuts:
		var lo: float = maxf(a0, g[0])
		var hi: float = minf(a1, g[1])
		if hi <= lo:
			continue
		_trim_seg(along_x, cursor, lo, fixed)
		cursor = maxf(cursor, hi)
	_trim_seg(along_x, cursor, a1, fixed)


func _trim_seg(along_x: bool, a0: float, a1: float, fixed: float) -> void:
	var length := a1 - a0
	if length < 0.16:
		return
	var mid := (a0 + a1) * 0.5
	var sx := length / TRIM_W
	if along_x:
		_push_trim(Vector3(mid, 0.05, fixed), Vector3.ZERO, sx, 1.0)
		_push_trim(Vector3(mid, 1.04, fixed), Vector3.ZERO, sx, 0.36)
	else:
		_push_trim(Vector3(fixed, 0.05, mid), Vector3(0, 90, 0), sx, 1.0)
		_push_trim(Vector3(fixed, 1.04, mid), Vector3(0, 90, 0), sx, 0.36)


func _push_trim(pos: Vector3, rot_deg: Vector3, sx: float, sy: float) -> void:
	var b := Basis.from_euler(rot_deg * PI / 180.0).scaled(Vector3(sx, sy, 1.0))
	_trim_x.append(Transform3D(b, pos))
	counts.trim += 1


func _commit_meshes(root: Node3D) -> void:
	_mm(root, "WallPanels", _mesh_panel, _mat_wall, _wall_x)
	_mm(root, "Trim", _mesh_trim, _mat_trim, _trim_x)
	_mm(root, "FloorTiles", _mesh_tile, _mat_carpet, _floor_x)
	_mm(root, "CeilingTiles", _mesh_tile, _mat_ceil, _ceil_x)
	_dress_boards(root)


func _mm(root: Node3D, name: String, mesh: Mesh, mat: Material, xforms: Array[Transform3D]) -> void:
	if xforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
	var mi := MultiMeshInstance3D.new()
	mi.name = name
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)


func _dress_boards(root: Node3D) -> void:
	# QA counts WallDressing/Baseboard_*. Own the closet+break run here.
	var walls := root.get_parent().get_node_or_null("WallDressing") as Node3D
	if walls == null:
		walls = Node3D.new()
		walls.name = "WallDressing"
		root.get_parent().add_child(walls)
	var i := 0
	for t in _trim_x:
		if t.origin.y > 0.20:
			continue
		var mi := MeshInstance3D.new()
		mi.name = "Baseboard_%d" % i
		mi.mesh = _mesh_trim
		mi.transform = t
		mi.material_override = _mat_trim
		mi.visible = false
		walls.add_child(mi)
		i += 1


func _shelf_runs(ic: Node) -> void:
	if ic == null:
		return
	_shelf_line(ic, "South", Vector3(-9.14, 0.0, 0.10), Vector3.RIGHT, Vector3.BACK, 6.16, 5)
	_shelf_line(ic, "North", Vector3(-9.14, 0.0, 6.32), Vector3.RIGHT, Vector3.FORWARD, 6.16, 5)
	_shelf_line(ic, "WestS", Vector3(-9.56, 0.0, 0.56), Vector3.BACK, Vector3.RIGHT, 2.06, 2)
	_shelf_line(ic, "WestN", Vector3(-9.56, 0.0, 3.90), Vector3.BACK, Vector3.RIGHT, 2.24, 2)


func _shelf_line(parent: Node, stem: String, origin: Vector3, along: Vector3, inward: Vector3, length: float, n_bays: int) -> void:
	along = along.normalized()
	inward = inward.normalized()
	var bay := length / float(n_bays)
	for i in n_bays:
		var mid := origin + along * ((float(i) + 0.5) * bay)
		_instance_bay(parent, "%s_Bay_%d" % [stem, i], mid, along, inward, bay, i)
		counts.shelf_bay += 1


func _instance_bay(parent: Node, name: String, mid: Vector3, along: Vector3, inward: Vector3, bay: float, seed: int) -> void:
	var root := Node3D.new()
	root.name = name
	root.position = mid
	parent.add_child(root)
	var depth := 0.44
	var sx := (bay - 0.048)
	var back := inward * 0.018
	var front := inward * (depth - 0.018)
	var left := along * (-bay * 0.5)
	var right := along * (bay * 0.5)
	_mi(root, "UprightBL", _mesh_upright, _mat_metal, back + left + Vector3(0, 1.40, 0), Vector3.ONE)
	_mi(root, "UprightFL", _mesh_upright, _mat_metal, front + left + Vector3(0, 1.40, 0), Vector3.ONE)
	_mi(root, "UprightBR", _mesh_upright, _mat_metal, back + right + Vector3(0, 1.40, 0), Vector3.ONE)
	_mi(root, "UprightFR", _mesh_upright, _mat_metal, front + right + Vector3(0, 1.40, 0), Vector3.ONE)
	var heights := [0.20, 0.74, 1.28, 1.82, 2.36]
	# _mesh_board is 1 x 0.028 x 0.388. Scale so along=sx, up=1, inward≈1.
	var along_axis := 0 if absf(along.x) > 0.5 else 2
	var in_axis := 2 if along_axis == 0 else 0
	for hi in heights.size():
		var bp := inward * (depth * 0.5) + Vector3(0, heights[hi], 0)
		var bs := Vector3.ONE
		bs[along_axis] = sx
		bs.y = 1.0
		bs[in_axis] = (depth - 0.052) / 0.388
		_mi(root, "Board_%d" % hi, _mesh_board, _mat_wood, bp, bs)
		var rp := inward * 0.012 + Vector3(0, heights[hi] + 0.055, 0)
		var rs := Vector3.ONE
		rs[along_axis] = bay - 0.06
		rs[in_axis] = 1.0
		_mi(root, "Rail_%d" % hi, _mesh_rail, _mat_metal, rp, rs, false)
		var n_boxes := 1 if hi == 4 or bay < 0.90 else 2
		for k in n_boxes:
			var t := (float(k) + 0.5) / float(n_boxes) - 0.5
			var yaw := _face_yaw(inward) + float(((seed + hi * 2 + k) % 5) - 2) * 3.0
			var bscale := 0.88 + 0.08 * float((seed + hi + k) % 4)
			var box_h := 0.20 * bscale
			var pos := along * (t * (bay - 0.16)) + inward * (depth * 0.50 + 0.02 * float(k - 1))
			pos.y = heights[hi] + 0.014 + box_h * 0.5
			_box_at(root, "Box_%d_%d" % [hi, k], pos, yaw, Vector3(bscale, bscale, bscale), false)


func _floor_boxes(ic: Node) -> void:
	if ic == null:
		return
	var spots := [
		[Vector3(-8.51, 0.10, 1.05), 18.0, Vector3(1.35, 1.20, 1.25)],
		[Vector3(-8.21, 0.08, 1.38), -12.0, Vector3(1.20, 0.95, 1.15)],
		[Vector3(-8.36, 0.08, 5.55), 8.0, Vector3(1.10, 0.90, 1.05)],
		[Vector3(-8.06, 0.07, 5.22), -22.0, Vector3(1.18, 0.85, 1.12)],
		[Vector3(-4.21, 0.07, 0.88), 14.0, Vector3(1.05, 0.80, 1.00)],
		[Vector3(-4.51, 0.09, 5.40), -8.0, Vector3(1.12, 0.95, 1.08)],
	]
	for i in spots.size():
		var s: Array = spots[i]
		_box_at(ic, "FloorBox_%d" % i, s[0], s[1], s[2], true)


func _box_at(parent: Node, name: String, pos: Vector3, yaw: float, scl: Vector3, collide: bool) -> void:
	var mi := MeshInstance3D.new()
	mi.name = name
	mi.mesh = _mesh_box
	mi.position = pos
	mi.rotation_degrees = Vector3(0, yaw, 0)
	mi.scale = scl
	mi.material_override = _mat_box
	parent.add_child(mi)
	if collide:
		var sb := StaticBody3D.new()
		sb.collision_layer = 1
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = Vector3(0.30, 0.20, 0.24)
		cs.shape = sh
		sb.add_child(cs)
		mi.add_child(sb)
	counts.box += 1


func _mi(parent: Node, name: String, mesh: Mesh, mat: Material, pos: Vector3, scl: Vector3, collide: bool = true) -> void:
	var mi := MeshInstance3D.new()
	mi.name = name
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scl
	mi.material_override = mat
	parent.add_child(mi)
	if collide:
		var sb := StaticBody3D.new()
		sb.collision_layer = 1
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		if mesh is BoxMesh:
			sh.size = (mesh as BoxMesh).size
		cs.shape = sh
		sb.add_child(cs)
		mi.add_child(sb)


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


func _fixtures(root: Node3D, level: Node3D) -> void:
	var fx := Node3D.new()
	fx.name = "Fixtures"
	root.add_child(fx)
	# Closet aisle troffers — warm practicals you can see.
	_troffer(fx, "ClosetTroffer_0", Vector3(-6.16, 2.93, 2.10), 0.0, Color(1.00, 0.82, 0.60), 2.85)
	_troffer(fx, "ClosetTroffer_1", Vector3(-6.16, 2.93, 4.40), 0.0, Color(1.00, 0.82, 0.60), 2.85)
	# Break room troffers.
	_troffer(fx, "BreakTroffer_0", Vector3(2.05, 2.93, 3.25), 90.0, Color(1.00, 0.84, 0.64), 2.55)
	_troffer(fx, "BreakTroffer_1", Vector3(3.50, 2.93, 3.25), 90.0, Color(1.00, 0.84, 0.64), 2.40)
	_troffer(fx, "BreakTroffer_2", Vector3(5.00, 2.93, 3.25), 90.0, Color(1.00, 0.84, 0.64), 2.55)
	# Under-cabinet warm strip (kitchenette, south wall).
	var strip := MeshInstance3D.new()
	strip.name = "UnderCabinetStrip"
	strip.mesh = _mesh_strip
	strip.position = Vector3(3.10, 0.94, 0.70)
	strip.material_override = _mat_fix
	fx.add_child(strip)
	var cab := OmniLight3D.new()
	cab.name = "UnderCabinetLight"
	cab.light_color = Color(1.00, 0.78, 0.52)
	cab.light_energy = 1.85
	cab.light_specular = 0.18
	cab.omni_range = 2.40
	cab.omni_attenuation = 1.15
	cab.shadow_enabled = false
	cab.position = Vector3(3.10, 0.90, 0.78)
	fx.add_child(cab)
	counts.fixture += 1
	# Cooler fills — fluorescent spill, not moonlight.
	_fill(fx, "ClosetCoolFill", Vector3(-4.10, 2.15, 3.25), Color(0.70, 0.82, 1.00), 0.72, 5.2)
	_fill(fx, "BreakCoolFill", Vector3(3.50, 2.20, 5.55), Color(0.72, 0.84, 1.00), 0.80, 5.6)
	_fill(fx, "BreakDoorFill", Vector3(3.50, 2.05, 6.10), Color(0.74, 0.86, 1.00), 0.55, 3.8)


func _troffer(parent: Node, name: String, pos: Vector3, yaw: float, color: Color, energy: float) -> void:
	var root := Node3D.new()
	root.name = name
	root.position = pos
	root.rotation_degrees = Vector3(0, yaw, 0)
	parent.add_child(root)
	_mi(root, "Housing", _mesh_housing, _mat_metal, Vector3.ZERO, Vector3.ONE, false)
	_mi(root, "Diffuser", _mesh_diffuser, _mat_fix, Vector3(0, -0.028, 0), Vector3.ONE, false)
	var o := OmniLight3D.new()
	o.name = "Practical"
	o.light_color = color
	o.light_energy = energy
	o.light_specular = 0.22
	o.omni_range = 4.80
	o.omni_attenuation = 1.05
	o.shadow_enabled = false
	o.position = Vector3(0, -0.22, 0)
	root.add_child(o)
	counts.fixture += 1


func _fill(parent: Node, name: String, pos: Vector3, color: Color, energy: float, rng: float) -> void:
	var o := OmniLight3D.new()
	o.name = name
	o.position = pos
	o.light_color = color
	o.light_energy = energy
	o.light_specular = 0.08
	o.omni_range = rng
	o.omni_attenuation = 1.20
	o.shadow_enabled = false
	parent.add_child(o)


func _retune_lights(level: Node3D) -> void:
	# Existing closet / break omnis become cooler fills so the new practicals key.
	# Do not touch WindowLight / hall / CEO / ambient.
	_tint(level, "Lights/IntroClosetLight", Color(0.78, 0.86, 0.98), 1.05, 6.4)
	_tint(level, "Lights/IntroClosetLight_02", Color(0.72, 0.82, 0.96), 0.70, 5.6)
	_tint(level, "Lights/IntroClosetLight_03", Color(0.72, 0.82, 0.96), 0.62, 5.2)
	_tint(level, "Lights/IntroClosetDoorLight", Color(1.00, 0.84, 0.62), 1.35, 3.6)
	_tint(level, "Lights/BreakRoomLight", Color(0.76, 0.84, 0.98), 1.25, 7.0)
	_tint(level, "Lights/KitchenLight", Color(1.00, 0.80, 0.56), 1.55, 3.6)


func _tint(level: Node3D, path: String, color: Color, energy: float, rng: float) -> void:
	var o := level.get_node_or_null(path) as OmniLight3D
	if o == null:
		return
	o.light_color = color
	o.light_energy = energy
	o.omni_range = rng
	o.light_specular = 0.12
