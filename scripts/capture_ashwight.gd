extends SceneTree
## Side still of the Ashwight so arm hide can be judged on Compatibility.

var _frames: int = 0


func _initialize() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var env_n := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.035, 0.028, 0.025)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.22, 0.18, 0.16)
	env.ambient_light_energy = 0.55
	env.sdfgi_enabled = false
	env_n.environment = env
	world.add_child(env_n)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-32, 48, 0)
	key.light_energy = 0.9
	key.light_color = Color(1.0, 0.86, 0.72)
	world.add_child(key)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-1.2, 1.6, 1.4)
	fill.light_energy = 0.45
	fill.omni_range = 6.0
	world.add_child(fill)
	var demon: Node3D = (load("res://scenes/demon.tscn") as PackedScene).instantiate()
	world.add_child(demon)
	var cam := Camera3D.new()
	cam.current = true
	cam.fov = 42.0
	world.add_child(cam)
	cam.look_at_from_position(Vector3(1.55, 1.35, 2.55), Vector3(0.05, 1.15, 0.05), Vector3.UP)


func _process(_dt: float) -> bool:
	_frames += 1
	if _frames < 18:
		return false
	var img := root.get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	img.save_png("/opt/cursor/artifacts/ashwight_arms.png")
	print("CAPTURE_OK ashwight_arms.png")
	quit(0)
	return true
