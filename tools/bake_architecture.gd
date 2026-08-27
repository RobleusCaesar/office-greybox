extends SceneTree
## Bake Architecture boolean CSG walls to ArrayMesh + ConcavePolygonShape3D.
## Simple boxes are converted by tools/rewrite_csg.py.

const BOOLEAN_WALLS := [
	"Architecture/Walls/BreakRoomWest",
	"Architecture/Walls/IntroClosetWest",
	"Architecture/Walls/IntroClosetEast",
	"Architecture/Walls/BreakRoomNorth",
	"Architecture/Walls/NorthHallWest",
	"Architecture/Walls/NorthHallEast",
	"Architecture/Walls/EastHallSouth",
	"Architecture/Walls/EastHallNorth",
	"Architecture/Walls/ReceptionWest",
	"Architecture/Walls/CEOEast",
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://scenes/baked")
	var packed: PackedScene = load("res://scenes/level.tscn")
	if packed == null:
		push_error("level.tscn failed to load")
		quit(1)
		return
	var level: Node = packed.instantiate()
	_strip_scripts(level)
	root.add_child(level)
	await process_frame
	await process_frame
	var manifest: Dictionary = {}
	for path in BOOLEAN_WALLS:
		var csg := level.get_node_or_null(path) as CSGShape3D
		if csg == null:
			push_error("missing CSG %s" % path)
			continue
		var mesh: ArrayMesh = csg.bake_static_mesh()
		if mesh == null or mesh.get_surface_count() == 0:
			push_error("bake_static_mesh empty for %s" % path)
			quit(1)
			return
		var col: Shape3D = csg.bake_collision_shape()
		var safe: String = path.replace("/", "_")
		var mesh_path: String = "res://scenes/baked/%s_mesh.res" % safe
		var col_path: String = "res://scenes/baked/%s_col.res" % safe
		var err_m: Error = ResourceSaver.save(mesh, mesh_path)
		var err_c: Error = OK
		if col:
			err_c = ResourceSaver.save(col, col_path)
		if err_m != OK or err_c != OK:
			push_error("save failed for %s mesh=%s col=%s" % [path, err_m, err_c])
			quit(1)
			return
		var size: Vector3 = Vector3.ZERO
		if csg is CSGBox3D:
			size = (csg as CSGBox3D).size
		manifest[path] = {
			"mesh": mesh_path,
			"col": col_path if col else "",
			"size": [size.x, size.y, size.z],
			"surfaces": mesh.get_surface_count(),
		}
		print("BAKED %s surfaces=%d size=%s" % [path, mesh.get_surface_count(), size])
	var json: String = JSON.stringify(manifest, "\t")
	var f := FileAccess.open("res://tools/csg_bake_manifest.json", FileAccess.WRITE)
	f.store_string(json)
	f.close()
	print("CSG_BAKE_OK %d walls" % manifest.size())
	quit(0)


func _strip_scripts(n: Node) -> void:
	n.set_script(null)
	for c in n.get_children():
		_strip_scripts(c)
