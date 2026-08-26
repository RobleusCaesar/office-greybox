extends CharacterBody3D
## First-person walker: shotgun primary, pistol secondary, hitscan, health.

const SPEED := 4.5
const JUMP_VELOCITY := 4.2
const MOUSE_SENS := 0.0024
const MAX_HP := 100.0

const SHOTGUN := 0
const PISTOL := 1

const SHOTGUN_PELLETS := 8
const SHOTGUN_SPREAD := 0.085
const SHOTGUN_RANGE := 14.0
const SHOTGUN_DAMAGE := 16.0
const SHOTGUN_FALLOFF := 6.0
const SHOTGUN_COOLDOWN := 0.78
const SHOTGUN_MAG := 4
const SHOTGUN_RESERVE := 12

const PISTOL_RANGE := 40.0
const PISTOL_DAMAGE := 28.0
const PISTOL_COOLDOWN := 0.26
const PISTOL_MAG := 12
const PISTOL_RESERVE := 36

signal died
signal health_changed(current: float, maximum: float)
signal ammo_changed(weapon_name: String, mag: int, reserve: int)

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D

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
var _hud_health: Label
var _hud_ammo: Label
var _hud_weapon: Label
var _snd_fire: AudioStreamPlayer
var _snd_reload: AudioStreamPlayer
var _snd_empty: AudioStreamPlayer
var _snd_hurt: AudioStreamPlayer


func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
			_set_weapon(SHOTGUN)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_weapon(PISTOL)
	elif event.is_action_pressed("weapon_1"):
		_set_weapon(SHOTGUN)
	elif event.is_action_pressed("weapon_2"):
		_set_weapon(PISTOL)
	elif event.is_action_pressed("reload"):
		_start_reload()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	if not dead and not input_locked and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Vector2.ZERO
	if not dead and not input_locked:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()

	_cool = maxf(0.0, _cool - delta)
	if _reloading:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_finish_reload()

	if not dead and not input_locked and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("fire"):
			_try_fire()

	_kick = _kick.lerp(Vector3.ZERO, clampf(delta * 9.0, 0.0, 1.0))
	_camera.rotation_degrees.x = _kick.x * 57.3
	_camera.rotation_degrees.y = _kick.y * 57.3
	if _weapon_root:
		_weapon_root.position = Vector3(0.22, -0.18, -0.38) + Vector3(0.0, _kick.x * 0.15, _kick.x * 0.25)
		_weapon_root.rotation_degrees.x = -8.0 - _kick.x * 40.0


func _try_fire() -> void:
	if _reloading or _cool > 0.0:
		return
	if _weapon == SHOTGUN:
		if _sg_mag <= 0:
			_click_empty()
			return
		_sg_mag -= 1
		_cool = SHOTGUN_COOLDOWN
		_kick.x += 0.085
		_kick.y += randf_range(-0.025, 0.025)
		_fire_hitscan(SHOTGUN_PELLETS, SHOTGUN_SPREAD, SHOTGUN_RANGE, SHOTGUN_DAMAGE, SHOTGUN_FALLOFF)
		if _snd_fire:
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
			collider.take_damage(damage * scale)


func _set_weapon(which: int) -> void:
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
	if _reloading or dead:
		return
	if _weapon == SHOTGUN:
		if _sg_mag >= SHOTGUN_MAG or _sg_res <= 0:
			return
		_reload_left = 1.15
	else:
		if _ps_mag >= PISTOL_MAG or _ps_res <= 0:
			return
		_reload_left = 0.85
	_reloading = true
	if _snd_reload:
		_snd_reload.play()


func _finish_reload() -> void:
	_reloading = false
	if _weapon == SHOTGUN:
		var need := SHOTGUN_MAG - _sg_mag
		var take: int = mini(need, _sg_res)
		_sg_mag += take
		_sg_res -= take
	else:
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
	if _hud_weapon:
		_hud_weapon.text = "SHOTGUN" if _weapon == SHOTGUN else "PISTOL"
	if _hud_ammo:
		var mag := _sg_mag if _weapon == SHOTGUN else _ps_mag
		var res := _sg_res if _weapon == SHOTGUN else _ps_res
		var suffix := "  ·  REL" if _reloading else ""
		_hud_ammo.text = "%d / %d%s" % [mag, res, suffix]


func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.45
	mat.metallic = 0.35
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)


func _build_weapons() -> void:
	_weapon_root = Node3D.new()
	_weapon_root.name = "WeaponRoot"
	_weapon_root.position = Vector3(0.22, -0.18, -0.38)
	_camera.add_child(_weapon_root)

	_shotgun_mesh = Node3D.new()
	_shotgun_mesh.name = "Shotgun"
	_weapon_root.add_child(_shotgun_mesh)
	_box(_shotgun_mesh, Vector3(0.07, 0.08, 0.22), Vector3(0.0, 0.0, 0.02), Color(0.12, 0.10, 0.08))
	_box(_shotgun_mesh, Vector3(0.045, 0.045, 0.42), Vector3(0.0, 0.02, -0.26), Color(0.18, 0.18, 0.20))
	_box(_shotgun_mesh, Vector3(0.038, 0.038, 0.38), Vector3(0.0, -0.02, -0.24), Color(0.16, 0.16, 0.18))
	_box(_shotgun_mesh, Vector3(0.05, 0.12, 0.16), Vector3(0.0, -0.08, 0.10), Color(0.10, 0.08, 0.06))
	_box(_shotgun_mesh, Vector3(0.06, 0.04, 0.10), Vector3(0.0, -0.04, -0.06), Color(0.08, 0.08, 0.09))

	_pistol_mesh = Node3D.new()
	_pistol_mesh.name = "Pistol"
	_pistol_mesh.visible = false
	_weapon_root.add_child(_pistol_mesh)
	_box(_pistol_mesh, Vector3(0.045, 0.055, 0.16), Vector3(0.0, 0.02, -0.04), Color(0.14, 0.14, 0.15))
	_box(_pistol_mesh, Vector3(0.035, 0.11, 0.055), Vector3(0.0, -0.06, 0.04), Color(0.10, 0.08, 0.06))
	_box(_pistol_mesh, Vector3(0.03, 0.03, 0.10), Vector3(0.0, 0.03, -0.14), Color(0.20, 0.20, 0.22))


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
	_hud_health.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_hud_health.position = Vector2(24, -56)
	_hud_ammo = _label(root, "4 / 12", Vector2(0, 0), Vector2(280, 40), 22, HORIZONTAL_ALIGNMENT_RIGHT)
	_hud_ammo.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hud_ammo.position = Vector2(-304, -56)
	_hud_weapon = _label(root, "SHOTGUN", Vector2(0, 0), Vector2(280, 28), 16, HORIZONTAL_ALIGNMENT_RIGHT)
	_hud_weapon.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hud_weapon.position = Vector2(-304, -84)

	var hint := _label(root, "LMB fire   R reload   1/2 or scroll weapons   Esc release mouse", Vector2(24, 16), Vector2(900, 28), 14, HORIZONTAL_ALIGNMENT_LEFT)
	hint.modulate = Color(1, 1, 1, 0.7)


func _build_audio() -> void:
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
