extends CharacterBody3D
## First-person walker: shotgun primary, pistol secondary, hitscan, health.

const SPEED := 4.5
const CROUCH_SPEED := 2.2
const CRAWL_SPEED := 1.35
const MOUSE_SENS := 0.0024
const MAX_HP := 100.0
const STAND_EYE := 1.7
const CROUCH_EYE := 1.05
const CRAWL_EYE := 0.52
const STAND_CAP := 1.8
const CROUCH_CAP := 1.15
const CRAWL_CAP := 0.72

const SHOTGUN := 0
const PISTOL := 1

const SHOTGUN_PELLETS := 8
const SHOTGUN_SPREAD := 0.085
const SHOTGUN_RANGE := 14.0
const SHOTGUN_DAMAGE := 16.0
const SHOTGUN_FALLOFF := 6.0
const SHOTGUN_COOLDOWN := 0.94
const SHOTGUN_MAG := 4
const SHOTGUN_RESERVE := 12
const SHOTGUN_SHELL_TIME := 0.48

const PISTOL_RANGE := 40.0
const PISTOL_DAMAGE := 28.0
const PISTOL_COOLDOWN := 0.26
const PISTOL_MAG := 12
const PISTOL_RESERVE := 36

const BLAST_PATH := "res://audio/shotgun_blast.wav"
const MAT_IMPACT: Material = preload("res://materials/mat_blood.tres")

signal died
signal health_changed(current: float, maximum: float)
signal ammo_changed(weapon_name: String, mag: int, reserve: int)

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _col: CollisionShape3D = $CollisionShape3D

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var hp: float = MAX_HP
var dead: bool = false
var input_locked: bool = false

var _weapon: int = SHOTGUN
var _cool: float = 0.0
var _reloading: bool = false
var _reload_left: float = 0.0
var _kick: Vector3 = Vector3.ZERO

var _sg_mag: int = SHOTGUN_MAG
var _sg_res: int = SHOTGUN_RESERVE
var _ps_mag: int = PISTOL_MAG
var _ps_res: int = PISTOL_RESERVE

var _weapon_root: Node3D
var _shotgun_mesh: Node3D
var _pistol_mesh: Node3D
var _hero_shotgun: Node3D
var _has_gun: bool = false
var crouched: bool = false
var crawling: bool = false
var _hud_health: Label
var _hud_ammo: Label
var _hud_weapon: Label
var _hud_prompt: Label
var _snd_fire: AudioStreamPlayer
var _snd_reload: AudioStreamPlayer
var _snd_empty: AudioStreamPlayer
var _snd_hurt: AudioStreamPlayer
var _gun_sfx: AudioStreamPlayer
var SND_BLAST: AudioStream = null


func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if _col and _col.shape:
		_col.shape = _col.shape.duplicate()
	_build_weapons()
	_build_hud()
	_build_audio()
	_emit_hud()


func get_look_camera() -> Camera3D:
	return _camera


func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(0.0, hp - amount)
	health_changed.emit(hp, MAX_HP)
	_update_hud()
	if _snd_hurt:
		_snd_hurt.play()
	_kick.x += 0.045
	if hp <= 0.0:
		_die()


func is_busy_ui() -> bool:
	return dead or input_locked


func _die() -> void:
	dead = true
	input_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	died.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if dead or input_locked:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		_head.rotate_x(-event.relative.y * MOUSE_SENS)
		_head.rotation.x = clampf(_head.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))
	elif event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if _has_gun:
				_set_weapon(SHOTGUN)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if _has_gun:
				_set_weapon(PISTOL)
	elif event.is_action_pressed("weapon_1"):
		if _has_gun:
			_set_weapon(SHOTGUN)
	elif event.is_action_pressed("weapon_2"):
		if _has_gun:
			_set_weapon(PISTOL)
	elif event.is_action_pressed("reload"):
		_start_reload()
	elif event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("crawl"):
		_toggle_crawl()


func _toggle_crawl() -> void:
	if dead or input_locked:
		return
	if crawling:
		if _can_leave_crawl():
			crawling = false
	else:
		crawling = true


func _can_leave_crawl() -> bool:
	var want := CROUCH_CAP if Input.is_action_pressed("crouch") else STAND_CAP
	return not _headroom_blocked(want)


func _headroom_blocked(height: float) -> bool:
	if height <= CRAWL_CAP + 0.02:
		return false
	var world := get_world_3d()
	if world == null:
		return true
	var space := world.direct_space_state
	if space == null:
		return true
	# Test the grown volume above the crawl capsule. A head-only probe
	# misses the thin VentDuct ceiling (bottom at Y=0.95).
	var extra := height - CRAWL_CAP
	var box := BoxShape3D.new()
	box.size = Vector3(0.40, extra, 0.40)
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = box
	q.transform = Transform3D(Basis(), global_position + Vector3(0.0, CRAWL_CAP + extra * 0.5, 0.0))
	q.collision_mask = collision_mask
	q.exclude = [get_rid()]
	q.margin = 0.02
	return not space.intersect_shape(q, 1).is_empty()


func _apply_stance(delta: float) -> float:
	crouched = (not dead and not input_locked and Input.is_action_pressed("crouch"))
	var eye := STAND_EYE
	var h := STAND_CAP
	var speed := SPEED
	if crawling and not dead:
		eye = CRAWL_EYE
		h = CRAWL_CAP
		speed = CRAWL_SPEED
	elif crouched:
		eye = CROUCH_EYE
		h = CROUCH_CAP
		speed = CROUCH_SPEED
	if _head:
		_head.position.y = lerpf(_head.position.y, eye, clampf(delta * 10.0, 0.0, 1.0))
	if _col and _col.shape is CapsuleShape3D:
		var cap := _col.shape as CapsuleShape3D
		cap.height = h
		_col.position.y = h * 0.5
	return speed


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var speed := _apply_stance(delta)

	var input_dir := Vector2.ZERO
	if not dead and not input_locked:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()

	_cool = maxf(0.0, _cool - delta)
	if _reloading:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_tick_reload()

	if not dead and not input_locked and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("fire"):
			_try_fire()

	_kick = _kick.lerp(Vector3.ZERO, clampf(delta * 7.2, 0.0, 1.0))
	_camera.rotation_degrees.x = _kick.x * 57.3
	_camera.rotation_degrees.y = _kick.y * 57.3
	if _weapon_root:
		_weapon_root.position = Vector3(0.20, -0.10, -0.26) + Vector3(0.0, _kick.x * 0.22, _kick.x * 0.38)
		_weapon_root.rotation_degrees.x = -10.0 - _kick.x * 58.0
	_update_prompt()


func add_ammo(shotgun_shells: int, pistol_rounds: int) -> void:
	_sg_res += shotgun_shells
	_ps_res += pistol_rounds
	_emit_hud()


func give_shotgun() -> void:
	if _has_gun:
		return
	_has_gun = true
	_weapon = SHOTGUN
	if _weapon_root:
		_weapon_root.visible = true
	if _shotgun_mesh:
		_shotgun_mesh.visible = true
	if _pistol_mesh:
		_pistol_mesh.visible = false
	_emit_hud()


func _try_interact() -> void:
	if dead or input_locked:
		return
	var pickup := _aimed_pickup()
	if pickup and pickup.has_method("try_pickup"):
		pickup.try_pickup(self)


func _aimed_pickup() -> Node:
	var space := get_world_3d().direct_space_state
	var origin := _camera.global_position
	var dest := origin + (-_camera.global_transform.basis.z) * 2.3
	var q := PhysicsRayQueryParameters3D.create(origin, dest)
	q.collide_with_areas = true
	q.collide_with_bodies = true
	q.collision_mask = 1 | 4
	q.exclude = [get_rid()]
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return null
	var n: Object = hit.collider
	if n is Node:
		var node := n as Node
		if node.is_in_group("ammo_pickup") or node.is_in_group("weapon_pickup"):
			return node
		if node.get_parent() and (node.get_parent().is_in_group("ammo_pickup") or node.get_parent().is_in_group("weapon_pickup")):
			return node.get_parent()
	return null


func _update_prompt() -> void:
	if _hud_prompt == null:
		return
	var pickup := _aimed_pickup()
	if pickup == null:
		_hud_prompt.visible = false
		return
	_hud_prompt.visible = true
	if pickup.is_in_group("weapon_pickup"):
		_hud_prompt.text = "E  take shotgun"
	else:
		_hud_prompt.text = "E  take ammo"


func _try_fire() -> void:
	if not _has_gun:
		return
	if _cool > 0.0:
		return
	if _reloading:
		if _weapon == SHOTGUN and _sg_mag > 0:
			_reloading = false
		else:
			return
	if _weapon == SHOTGUN:
		if _sg_mag <= 0:
			_click_empty()
			return
		_sg_mag -= 1
		_cool = SHOTGUN_COOLDOWN
		_kick.x += 0.175
		_kick.y += randf_range(-0.04, 0.04)
		_fire_hitscan(SHOTGUN_PELLETS, SHOTGUN_SPREAD, SHOTGUN_RANGE, SHOTGUN_DAMAGE, SHOTGUN_FALLOFF)
		if _hero_shotgun and _hero_shotgun.has_method("fire"):
			_hero_shotgun.fire()
		if _gun_sfx and SND_BLAST:
			_gun_sfx.stream = SND_BLAST
			_gun_sfx.play()
		elif _snd_fire:
			# WAVS_MISSING fallback — same blast as current main.
			_snd_fire.stream = load("res://audio/shotgun_fire.wav")
			_snd_fire.play()
	else:
		if _ps_mag <= 0:
			_click_empty()
			return
		_ps_mag -= 1
		_cool = PISTOL_COOLDOWN
		_kick.x += 0.028
		_kick.y += randf_range(-0.01, 0.01)
		_fire_hitscan(1, 0.006, PISTOL_RANGE, PISTOL_DAMAGE, 22.0)
		if _snd_fire:
			_snd_fire.stream = load("res://audio/pistol_fire.wav")
			_snd_fire.play()
	_emit_hud()


func _click_empty() -> void:
	if _snd_empty:
		_snd_empty.play()


func _fire_hitscan(pellets: int, spread: float, max_range: float, damage: float, falloff: float) -> void:
	var space := get_world_3d().direct_space_state
	var origin := _camera.global_position
	var forward := -_camera.global_transform.basis.z
	var right := _camera.global_transform.basis.x
	var up := _camera.global_transform.basis.y
	for _i in pellets:
		var dir := (forward + right * randf_range(-spread, spread) + up * randf_range(-spread, spread)).normalized()
		var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * max_range)
		query.collision_mask = 1 | 4
		query.exclude = [get_rid()]
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			continue
		var dist: float = origin.distance_to(hit.position)
		var scale := 1.0 if dist <= falloff else clampf(1.0 - (dist - falloff) / maxf(0.01, max_range - falloff), 0.2, 1.0)
		var collider: Object = hit.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage * scale, hit.position, hit.normal)
		_spawn_impact(hit.position, hit.normal)


func _spawn_impact(pos: Vector3, nrm: Vector3) -> void:
	# Duplicate the shared .tres — never mutate MAT_IMPACT in place (that's the hitch).
	var mi := MeshInstance3D.new()
	mi.name = "BloodSplat"
	var q := QuadMesh.new()
	q.size = Vector2(0.20, 0.20)
	mi.mesh = q
	var mat := (MAT_IMPACT as StandardMaterial3D).duplicate() as StandardMaterial3D
	mat.albedo_color = Color(0.38, 0.02, 0.05, 0.82)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission_enabled = false
	mi.material_override = mat
	var host: Node = get_parent()
	if host == null:
		host = self
	host.add_child(mi)
	mi.global_position = pos + nrm.normalized() * 0.012
	var up := nrm.normalized() if nrm.length() > 0.01 else Vector3.UP
	var tmp := Vector3.RIGHT if absf(up.dot(Vector3.UP)) > 0.92 else Vector3.UP
	var xaxis := up.cross(tmp).normalized()
	var yaxis := xaxis.cross(up).normalized()
	mi.global_transform.basis = Basis(xaxis, yaxis, up)
	var tw := create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.72)
	tw.tween_callback(mi.queue_free)


func _set_weapon(which: int) -> void:
	if not _has_gun:
		return
	if _weapon == which:
		return
	_weapon = which
	_reloading = false
	if _shotgun_mesh:
		_shotgun_mesh.visible = _weapon == SHOTGUN
	if _pistol_mesh:
		_pistol_mesh.visible = _weapon == PISTOL
	_emit_hud()


func _start_reload() -> void:
	if not _has_gun or _reloading or dead:
		return
	if _weapon == SHOTGUN:
		if _sg_mag >= SHOTGUN_MAG or _sg_res <= 0 or _cool > 0.0:
			return
		_reload_left = SHOTGUN_SHELL_TIME
	else:
		if _ps_mag >= PISTOL_MAG or _ps_res <= 0:
			return
		_reload_left = 0.85
	_reloading = true
	# Shotgun R: only hero_shotgun.insert_shell → shotgun_reloading. No reload.wav one-shot.
	if _weapon == PISTOL and _snd_reload:
		_snd_reload.play()


func _tick_reload() -> void:
	if _weapon == SHOTGUN:
		if _sg_res <= 0 or _sg_mag >= SHOTGUN_MAG:
			_reloading = false
			_emit_hud()
			return
		_sg_mag += 1
		_sg_res -= 1
		if _hero_shotgun and _hero_shotgun.has_method("insert_shell"):
			_hero_shotgun.insert_shell()
		if _sg_mag < SHOTGUN_MAG and _sg_res > 0:
			_reload_left = SHOTGUN_SHELL_TIME
		else:
			_reloading = false
	else:
		_reloading = false
		var need := PISTOL_MAG - _ps_mag
		var take: int = mini(need, _ps_res)
		_ps_mag += take
		_ps_res -= take
	_emit_hud()


func _emit_hud() -> void:
	var wname := "SHOTGUN" if _weapon == SHOTGUN else "PISTOL"
	var mag := _sg_mag if _weapon == SHOTGUN else _ps_mag
	var res := _sg_res if _weapon == SHOTGUN else _ps_res
	ammo_changed.emit(wname, mag, res)
	health_changed.emit(hp, MAX_HP)
	_update_hud()


func _update_hud() -> void:
	if _hud_health:
		_hud_health.text = "HP  %d" % int(hp)
	if not _has_gun:
		if _hud_weapon:
			_hud_weapon.text = ""
		if _hud_ammo:
			_hud_ammo.text = ""
		return
	if _hud_weapon:
		_hud_weapon.text = "SHOTGUN" if _weapon == SHOTGUN else "PISTOL"
	if _hud_ammo:
		var mag := _sg_mag if _weapon == SHOTGUN else _ps_mag
		var res := _sg_res if _weapon == SHOTGUN else _ps_res
		var suffix := "  ·  REL" if _reloading else ""
		_hud_ammo.text = "%d / %d%s" % [mag, res, suffix]


func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, wood: bool = false) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.albedo_texture = load("res://textures/tex_wood.png" if wood else "res://textures/tex_gun.png")
	mat.roughness = 0.42 if wood else 0.32
	mat.metallic = 0.08 if wood else 0.72
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)


func _build_weapons() -> void:
	_weapon_root = Node3D.new()
	_weapon_root.name = "WeaponRoot"
	_weapon_root.position = Vector3(0.20, -0.10, -0.26)
	_camera.add_child(_weapon_root)

	_hero_shotgun = (load("res://scripts/hero_shotgun.gd") as GDScript).new()
	_shotgun_mesh = _hero_shotgun
	_weapon_root.add_child(_hero_shotgun)

	_pistol_mesh = Node3D.new()
	_pistol_mesh.name = "Pistol"
	_pistol_mesh.visible = false
	_weapon_root.add_child(_pistol_mesh)
	# Spawn unarmed — no holster gun, no shotgun in hands until E pickup.
	_weapon_root.visible = false
	_shotgun_mesh.visible = false
	_box(_pistol_mesh, Vector3(0.045, 0.055, 0.16), Vector3(0.0, 0.02, -0.04), Color(0.50, 0.50, 0.52))
	_box(_pistol_mesh, Vector3(0.035, 0.11, 0.055), Vector3(0.0, -0.06, 0.04), Color(0.38, 0.24, 0.14), true)
	_box(_pistol_mesh, Vector3(0.03, 0.03, 0.10), Vector3(0.0, 0.03, -0.14), Color(0.58, 0.58, 0.60))


func _dock(parent: Control, lab: Label, left: bool, top_off: float, font_size: int) -> void:
	lab.set_anchors_preset(Control.PRESET_BOTTOM_LEFT if left else Control.PRESET_BOTTOM_RIGHT)
	lab.anchor_top = 1.0
	lab.anchor_bottom = 1.0
	if left:
		lab.anchor_left = 0.0
		lab.anchor_right = 0.0
		lab.offset_left = 24
		lab.offset_right = 360
	else:
		lab.anchor_left = 1.0
		lab.anchor_right = 1.0
		lab.offset_left = -360
		lab.offset_right = -24
	lab.offset_top = top_off
	lab.offset_bottom = top_off + 40
	lab.add_theme_font_size_override("font_size", font_size)
	parent.move_child(lab, -1)


func _label(parent: Control, text: String, pos: Vector2, size: Vector2, font_size: int, align: HorizontalAlignment) -> Label:
	var lab := Label.new()
	lab.text = text
	lab.position = pos
	lab.size = size
	lab.horizontal_alignment = align
	lab.add_theme_font_size_override("font_size", font_size)
	lab.add_theme_color_override("font_color", Color(0.92, 0.90, 0.86, 0.92))
	lab.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	lab.add_theme_constant_override("shadow_offset_x", 1)
	lab.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(lab)
	return lab


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var cross := Label.new()
	cross.text = "+"
	cross.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cross.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-16, -16)
	cross.size = Vector2(32, 32)
	cross.add_theme_font_size_override("font_size", 22)
	cross.add_theme_color_override("font_color", Color(1, 1, 1, 0.72))
	root.add_child(cross)

	_hud_health = _label(root, "HP  100", Vector2(24, 660), Vector2(280, 40), 22, HORIZONTAL_ALIGNMENT_LEFT)
	_dock(root, _hud_health, true, -64, 22)
	_hud_ammo = _label(root, "4 / 12", Vector2(0, 0), Vector2(280, 40), 22, HORIZONTAL_ALIGNMENT_RIGHT)
	_dock(root, _hud_ammo, false, -64, 22)
	_hud_weapon = _label(root, "SHOTGUN", Vector2(0, 0), Vector2(280, 28), 16, HORIZONTAL_ALIGNMENT_RIGHT)
	_dock(root, _hud_weapon, false, -96, 16)

	var hint := _label(root, "WASD move · Mouse look · LMB fire · R reload · 1 shotgun · 2 pistol · Space crouch · C crawl · E use · Esc release", Vector2(24, 16), Vector2(1040, 28), 14, HORIZONTAL_ALIGNMENT_LEFT)
	hint.modulate = Color(1, 1, 1, 0.7)
	var mark := _label(root, "HELLFALL", Vector2(0, 0), Vector2(280, 28), 16, HORIZONTAL_ALIGNMENT_RIGHT)
	mark.name = "TitleMark"
	mark.add_theme_color_override("font_color", Color(0.93, 0.88, 0.78, 0.92))
	mark.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	mark.anchor_left = 1.0
	mark.anchor_right = 1.0
	mark.anchor_top = 0.0
	mark.anchor_bottom = 0.0
	mark.offset_left = -300
	mark.offset_right = -24
	mark.offset_top = 16
	mark.offset_bottom = 44
	_hud_prompt = _label(root, "E  take ammo", Vector2(0, 0), Vector2(240, 32), 18, HORIZONTAL_ALIGNMENT_CENTER)
	_hud_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hud_prompt.anchor_left = 0.5
	_hud_prompt.anchor_right = 0.5
	_hud_prompt.anchor_top = 1.0
	_hud_prompt.anchor_bottom = 1.0
	_hud_prompt.offset_left = -120
	_hud_prompt.offset_right = 120
	_hud_prompt.offset_top = -120
	_hud_prompt.offset_bottom = -80
	_hud_prompt.visible = false


func _build_audio() -> void:
	# load() only — packed-res probes miss remapped wavs on HTML5.
	SND_BLAST = load(BLAST_PATH) as AudioStream
	if SND_BLAST == null:
		SND_BLAST = load("res://audio/shotgun_fire.wav") as AudioStream
	_gun_sfx = AudioStreamPlayer.new()
	_gun_sfx.name = "GunSfx"
	_gun_sfx.volume_db = -2.0
	add_child(_gun_sfx)
	_snd_fire = AudioStreamPlayer.new()
	_snd_fire.volume_db = -4.0
	add_child(_snd_fire)
	_snd_reload = AudioStreamPlayer.new()
	_snd_reload.stream = load("res://audio/reload.wav")
	_snd_reload.volume_db = -8.0
	add_child(_snd_reload)
	_snd_empty = AudioStreamPlayer.new()
	_snd_empty.stream = load("res://audio/empty.wav")
	_snd_empty.volume_db = -10.0
	add_child(_snd_empty)
	_snd_hurt = AudioStreamPlayer.new()
	_snd_hurt.stream = load("res://audio/hurt.wav")
	_snd_hurt.volume_db = -6.0
	add_child(_snd_hurt)
