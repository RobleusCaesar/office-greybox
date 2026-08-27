extends Node3D
## Articulated first-person pump shotgun: walnut + worn steel, tanned hands,
## wedding band on the LEFT ring finger. Pump after every shot.

const PUMP_TRAVEL := 0.092
const CYCLE := 0.94

var _pump: Node3D
var _muzzle: Node3D
var _eject: Node3D
var _flash_light: OmniLight3D
var _flash_mesh: MeshInstance3D
var _tongues: Array[MeshInstance3D] = []
var _sparks: CPUParticles3D
var _smoke: CPUParticles3D
var _hang: CPUParticles3D
var _residual: CPUParticles3D
var _flash_left: float = 0.0
var _pump_t: float = 1.0
var _pumping: bool = false
var _cock_sfx: AudioStreamPlayer
var _reload_sfx: AudioStreamPlayer
var _cocked_this_cycle: bool = false


func _ready() -> void:
	_build()
	_build_sfx()


func is_cycling() -> bool:
	return _pumping


func fire() -> void:
	_flash_left = 0.085
	_pumping = true
	_pump_t = 0.0
	_cocked_this_cycle = false
	if _sparks:
		_sparks.restart()
	if _smoke:
		_smoke.restart()
	if _hang:
		_hang.restart()
	if _residual:
		_residual.restart()
	play_cycle()


func play_cycle() -> void:
	# Cycle is the existing fire pump (CYCLE / PUMP_TRAVEL unchanged).
	# Cock SFX fires when that pump starts in _apply_pump.
	return


func _play_close_pump() -> void:
	_play_cock()


func _play_cock() -> void:
	if _cock_sfx and _cock_sfx.stream:
		_cock_sfx.play()


func insert_shell() -> void:
	_insert_one()


func _insert_one() -> void:
	if _pump:
		var tw := create_tween()
		tw.tween_property(_pump, "position:z", PUMP_TRAVEL * 0.22, 0.08)
		tw.tween_property(_pump, "position:z", 0.0, 0.12)
	_play_reload()


func _play_reload() -> void:
	if _reload_sfx == null or _reload_sfx.stream == null:
		return
	_reload_sfx.play()
	var dur := _reload_sfx.stream.get_length()
	if dur > 0.0 and dur < 0.34:
		var replay := get_tree().create_timer(dur)
		replay.timeout.connect(func() -> void:
			if is_instance_valid(_reload_sfx) and _reload_sfx.stream:
				_reload_sfx.play()
		)


func _build_sfx() -> void:
	_cock_sfx = AudioStreamPlayer.new()
	_cock_sfx.name = "CockSfx"
	_cock_sfx.volume_db = -2.0
	_cock_sfx.stream = load("res://audio/shotgun_cocking.wav") as AudioStream
	add_child(_cock_sfx)
	_reload_sfx = AudioStreamPlayer.new()
	_reload_sfx.name = "ReloadSfx"
	_reload_sfx.volume_db = -3.0
	_reload_sfx.stream = load("res://audio/shotgun_reloading.wav") as AudioStream
	add_child(_reload_sfx)


func _process(delta: float) -> void:
	if _pumping:
		_pump_t = minf(1.0, _pump_t + delta / CYCLE)
		_apply_pump(_pump_t)
		if _pump_t >= 1.0:
			_pumping = false
	_flash_left = maxf(0.0, _flash_left - delta)
	var on := _flash_left > 0.0
	if _flash_light:
		_flash_light.light_energy = 6.4 * (_flash_left / 0.085) if on else 0.0
		_flash_light.visible = on
	if _flash_mesh:
		_flash_mesh.visible = on
		_flash_mesh.scale = Vector3.ONE * (0.7 + (1.0 - _flash_left / 0.085) * 0.8)
	for t in _tongues:
		t.visible = on
		if on:
			t.rotation.z = sin(Time.get_ticks_msec() * 0.04 + t.position.x * 20.0) * 0.35
			t.scale.y = 0.6 + _flash_left * 8.0


func _apply_pump(t: float) -> void:
	if _pump == null:
		return
	var slide := 0.0
	if t < 0.14:
		slide = 0.0
	elif t < 0.46:
		if not _cocked_this_cycle:
			_cocked_this_cycle = true
			_play_cock()
		slide = smoothstep(0.14, 0.46, t) * PUMP_TRAVEL
	elif t < 0.78:
		slide = (1.0 - smoothstep(0.46, 0.78, t)) * PUMP_TRAVEL
	_pump.position.z = slide


func _wood() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.72, 0.48, 0.28)
	m.albedo_texture = load("res://textures/hero/shotgun-walnut-steel.png")
	var close := load("res://textures/hero/tex-walnut-close.png")
	if close:
		m.albedo_texture = close
	m.roughness = 0.62
	m.metallic = 0.04
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return m


func _steel() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.38, 0.39, 0.41)
	var steel := load("res://textures/hero/tex-worn-steel.png")
	m.albedo_texture = steel if steel else load("res://textures/hero/shotgun-walnut-steel.png")
	m.roughness = 0.52
	m.metallic = 0.58
	m.metallic_specular = 0.28
	return m


func _skin() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.72, 0.5, 0.36)
	m.albedo_texture = load("res://textures/hero/tex-hand-tan.png")
	m.roughness = 0.58
	m.metallic = 0.0
	return m


func _band() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.62, 0.62, 0.64)
	m.roughness = 0.38
	m.metallic = 0.72
	return m


func _box(parent: Node3D, name: String, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _cyl(parent: Node3D, name: String, r: float, h: float, pos: Vector3, mat: Material, axis: Vector3 = Vector3(1, 0, 0)) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = r
	mesh.bottom_radius = r
	mesh.height = h
	mesh.radial_segments = 12
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = axis
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _build() -> void:
	name = "HeroShotgun"
	var wood := _wood()
	var steel := _steel()
	var skin := _skin()

	var receiver := Node3D.new()
	receiver.name = "Receiver"
	add_child(receiver)
	_box(receiver, "Body", Vector3(0.052, 0.058, 0.20), Vector3(0.0, 0.012, 0.02), steel)
	_box(receiver, "EjectionPort", Vector3(0.018, 0.028, 0.07), Vector3(0.028, 0.018, 0.01), steel)
	_box(receiver, "TriggerGuard", Vector3(0.018, 0.032, 0.046), Vector3(0.0, -0.036, 0.05), steel)
	_box(receiver, "Trigger", Vector3(0.008, 0.02, 0.01), Vector3(0.0, -0.03, 0.048), steel)

	_cyl(self, "Barrel", 0.013, 0.46, Vector3(0.0, 0.026, -0.28), steel, Vector3(1.5708, 0, 0))
	_cyl(self, "MagTube", 0.011, 0.36, Vector3(0.0, -0.006, -0.22), steel, Vector3(1.5708, 0, 0))
	_box(self, "Bead", Vector3(0.006, 0.008, 0.006), Vector3(0.0, 0.042, -0.50), steel)

	var stock := Node3D.new()
	stock.name = "Stock"
	add_child(stock)
	_box(stock, "Wrist", Vector3(0.046, 0.05, 0.10), Vector3(0.0, -0.01, 0.14), wood)
	_box(stock, "Comb", Vector3(0.05, 0.072, 0.16), Vector3(0.0, 0.01, 0.26), wood)
	_box(stock, "RecoilPad", Vector3(0.054, 0.078, 0.018), Vector3(0.0, 0.008, 0.348), steel)
	_box(stock, "Grip", Vector3(0.042, 0.09, 0.05), Vector3(0.0, -0.055, 0.10), wood)

	_pump = Node3D.new()
	_pump.name = "Pump"
	_pump.position = Vector3(0.0, -0.004, -0.12)
	add_child(_pump)
	_box(_pump, "Forend", Vector3(0.048, 0.042, 0.13), Vector3.ZERO, wood)
	for i in 6:
		_box(_pump, "Rib_%d" % i, Vector3(0.052, 0.046, 0.01), Vector3(0.0, 0.0, -0.05 + i * 0.018), wood)

	_hand(_pump, "HandL", Vector3(-0.034, -0.03, 0.01), skin, true)
	_hand(self, "HandR", Vector3(0.03, -0.07, 0.09), skin, false)

	_muzzle = Node3D.new()
	_muzzle.name = "Muzzle"
	_muzzle.position = Vector3(0.0, 0.026, -0.52)
	add_child(_muzzle)
	_build_muzzle()

	_eject = Node3D.new()
	_eject.name = "Ejection"
	_eject.position = Vector3(0.03, 0.02, 0.01)
	add_child(_eject)
	_residual = _smoke_burst(_eject, 10, 0.9, Vector3(0.6, 0.2, 0.1), 0.35)
	_residual.emitting = false


func _hand(parent: Node3D, name: String, pos: Vector3, skin: Material, left: bool) -> void:
	var hand := Node3D.new()
	hand.name = name
	hand.position = pos
	hand.rotation_degrees = Vector3(-12 if left else -28, 8 if left else -6, 70 if left else -18)
	parent.add_child(hand)
	_box(hand, "Palm", Vector3(0.034, 0.016, 0.05), Vector3.ZERO, skin)
	var side := -1.0 if left else 1.0
	var names := ["Index", "Middle", "Ring", "Pinky"]
	for i in 4:
		var finger := Node3D.new()
		finger.name = names[i]
		finger.position = Vector3(side * 0.012, 0.0, -0.028 - i * 0.002)
		hand.add_child(finger)
		_box(finger, "P1", Vector3(0.009, 0.009, 0.022), Vector3(0, 0, -0.012), skin)
		_box(finger, "P2", Vector3(0.008, 0.008, 0.018), Vector3(0, 0, -0.030), skin)
		if left and i == 2:
			var band := MeshInstance3D.new()
			band.name = "WeddingBand"
			var torus := TorusMesh.new()
			torus.inner_radius = 0.0036
			torus.outer_radius = 0.0052
			torus.rings = 10
			torus.ring_segments = 8
			band.mesh = torus
			band.position = Vector3(0, 0, -0.021)
			band.rotation_degrees = Vector3(90, 0, 0)
			band.material_override = _band()
			finger.add_child(band)
	var thumb := Node3D.new()
	thumb.name = "Thumb"
	thumb.position = Vector3(side * -0.016, 0.004, -0.006)
	thumb.rotation_degrees = Vector3(0, 28 * side, 0)
	hand.add_child(thumb)
	_box(thumb, "P1", Vector3(0.01, 0.01, 0.02), Vector3(0, 0, -0.01), skin)


func _build_muzzle() -> void:
	_flash_light = OmniLight3D.new()
	_flash_light.name = "FlashLight"
	_flash_light.light_color = Color(1.0, 0.62, 0.28)
	_flash_light.light_energy = 0.0
	_flash_light.omni_range = 3.2
	_flash_light.visible = false
	_muzzle.add_child(_flash_light)

	_flash_mesh = MeshInstance3D.new()
	_flash_mesh.name = "Flash"
	var sph := SphereMesh.new()
	sph.radius = 0.028
	sph.height = 0.04
	_flash_mesh.mesh = sph
	var flash_mat := StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1.0, 0.72, 0.28, 0.85)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1.0, 0.55, 0.12)
	flash_mat.emission_energy_multiplier = 4.2
	flash_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_flash_mesh.material_override = flash_mat
	_flash_mesh.visible = false
	_muzzle.add_child(_flash_mesh)

	for i in 3:
		var tongue := MeshInstance3D.new()
		tongue.name = "Tongue_%d" % i
		var prism := PrismMesh.new()
		prism.size = Vector3(0.012, 0.07, 0.008)
		tongue.mesh = prism
		tongue.position = Vector3((i - 1) * 0.01, 0.0, -0.02)
		tongue.rotation_degrees = Vector3(-90, 0, (i - 1) * 18)
		var tm := StandardMaterial3D.new()
		tm.albedo_color = Color(1.0, 0.45 + i * 0.1, 0.08, 0.7)
		tm.emission_enabled = true
		tm.emission = Color(1.0, 0.4, 0.05)
		tm.emission_energy_multiplier = 3.4
		tm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tongue.material_override = tm
		tongue.visible = false
		_muzzle.add_child(tongue)
		_tongues.append(tongue)

	_sparks = _spark_burst(_muzzle)
	_smoke = _smoke_burst(_muzzle, 14, 0.7, Vector3(0, 0.15, -0.4), 0.55)
	_hang = _smoke_burst(_muzzle, 8, 1.8, Vector3(0, 0.35, -0.15), 0.22)
	_smoke.emitting = false
	_hang.emitting = false
	_sparks.emitting = false


func _spark_burst(parent: Node3D) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.name = "Sparks"
	p.amount = 18
	p.lifetime = 0.28
	p.one_shot = true
	p.explosiveness = 0.95
	p.direction = Vector3(0, 0.1, -1)
	p.spread = 28.0
	p.initial_velocity_min = 2.4
	p.initial_velocity_max = 5.2
	p.gravity = Vector3(0, -3.5, 0)
	p.scale_amount_min = 0.008
	p.scale_amount_max = 0.016
	var qm := SphereMesh.new()
	qm.radius = 0.006
	qm.height = 0.012
	p.mesh = qm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.7, 0.25)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.55, 0.1)
	mat.emission_energy_multiplier = 3.8
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	p.material_override = mat
	parent.add_child(p)
	return p


func _smoke_burst(parent: Node3D, amount: int, life: float, dir: Vector3, speed: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.name = "Smoke"
	p.amount = amount
	p.lifetime = life
	p.one_shot = true
	p.explosiveness = 0.35
	p.direction = dir
	p.spread = 18.0
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.gravity = Vector3(0, 0.15, 0)
	p.scale_amount_min = 0.02
	p.scale_amount_max = 0.06
	var qm := QuadMesh.new()
	qm.size = Vector2(0.05, 0.05)
	p.mesh = qm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.16, 0.14, 0.35)
	mat.albedo_texture = load("res://textures/tex_smoke.png")
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	p.material_override = mat
	parent.add_child(p)
	return p
