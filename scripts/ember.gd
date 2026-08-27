extends CharacterBody3D
## Ember Demon — molten winged enemy at DemonSpot_Reception.
## Soft-loads models/ember_demon.glb. Placeholder mesh if the 47MB file is absent.
## Stalker stays on Demon_01 / enemy.gd. Do not reuse those clip locks.

enum State { IDLE, CHASE, TELEGRAPH, RECOVER, DEAD }

const GLB_PATH := "res://models/ember_demon.glb"

const CLIP_IDLE := "Idle_8"
const CLIP_CHASE := "Walking"
const CLIP_ATTACK := "Attack"
const CLIP_DEATH := "Shot_and_Fall_Backward"
const CLIP_HIT := "Hit_Reaction"

const ATTACK_CLIP_FALLBACK := 2.20
const VISUAL_SCALE := 1.0
const EMISSION_CAP := 0.55
const LOS_EYE := 1.35
const PLACEHOLDER_HEIGHT := 1.70

@export var max_hp: float = 120.0
@export var move_speed: float = 3.05
@export var attack_damage: float = 16.0
@export var attack_range: float = 1.55
@export var aggro_range: float = 7.4
@export var telegraph_time: float = 2.20
@export var recover_time: float = 0.70

var hp: float = 120.0
var state: State = State.IDLE

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _timer: float = 0.0
var _visual: Node3D
var _ap: AnimationPlayer
var _snd: AudioStreamPlayer3D
var _dead: bool = false
var _shot_gate: float = 0.0
var _hit_stun: float = 0.0
var _growls: Dictionary = {}
var _clips: Dictionary = {}
var _clip_names: PackedStringArray = PackedStringArray()
var _first_seen: bool = false
var _see_growl: AudioStream


func _ready() -> void:
	hp = max_hp
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("enemies")
	_instance_visual()
	_load_growls()
	_see_growl = load("res://audio/deamon_growl.wav")
	_snd = AudioStreamPlayer3D.new()
	_snd.volume_db = -2.0
	_snd.max_distance = 18.0
	add_child(_snd)
	_play_growl("idle")
	_play_clip(CLIP_IDLE)


func imported_clip_names() -> PackedStringArray:
	return _clip_names


func take_damage(amount: float, hit_pos: Vector3 = Vector3.ZERO, hit_normal: Vector3 = Vector3.UP) -> void:
	if _dead:
		return
	if amount <= 20.0:
		if _shot_gate > 0.0:
			return
		_shot_gate = 0.12
		hp -= clampf(amount, 24.0, 32.0)
	else:
		hp -= amount
	if hit_pos != Vector3.ZERO:
		_spawn_body_splat(hit_pos, hit_normal)
		_spawn_spray(hit_pos, hit_normal)
	else:
		var fallback := global_position + Vector3(0, 1.15, 0)
		_spawn_body_splat(fallback, Vector3.UP)
		_spawn_spray(fallback, Vector3.UP)
	_play_growl("pain")
	if state == State.IDLE:
		state = State.CHASE
	if not _dead and _resolve(CLIP_HIT) != "":
		_play_clip(CLIP_HIT)
		_hit_stun = 0.32
	if hp <= 0.0:
		_die()


func _die() -> void:
	_dead = true
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	velocity = Vector3.ZERO
	_play_growl("death")
	_play_clip(CLIP_DEATH)


func _physics_process(delta: float) -> void:
	_shot_gate = maxf(0.0, _shot_gate - delta)
	_hit_stun = maxf(0.0, _hit_stun - delta)
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if _dead:
		move_and_slide()
		return

	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null or ("dead" in player and player.dead):
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	_maybe_first_see(player)

	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()
	var dir := to_player.normalized() if dist > 0.01 else Vector3.ZERO

	match state:
		State.IDLE:
			velocity.x = 0.0
			velocity.z = 0.0
			if _hit_stun <= 0.0:
				_keep_anim(CLIP_IDLE)
			if dist <= aggro_range and _has_los(player):
				state = State.CHASE
				_play_growl("chase")
		State.CHASE:
			if _hit_stun <= 0.0:
				_keep_anim(CLIP_CHASE)
			if dir != Vector3.ZERO:
				_face_plus_z(dir)
			if dist <= attack_range:
				state = State.TELEGRAPH
				_timer = _attack_hold()
				velocity.x = 0.0
				velocity.z = 0.0
				_play_clip(CLIP_ATTACK)
				_play_growl("attack")
			else:
				velocity.x = dir.x * move_speed
				velocity.z = dir.z * move_speed
		State.TELEGRAPH:
			_timer -= delta
			velocity.x = 0.0
			velocity.z = 0.0
			if dir != Vector3.ZERO:
				_face_plus_z(dir)
			if _timer <= 0.0:
				if dist <= attack_range + 0.35 and player.has_method("take_damage"):
					player.take_damage(attack_damage)
				state = State.RECOVER
				_timer = recover_time
		State.RECOVER:
			_timer -= delta
			velocity.x = 0.0
			velocity.z = 0.0
			if _timer <= 0.0:
				state = State.CHASE

	move_and_slide()


func _face_plus_z(dir: Vector3) -> void:
	rotation.y = atan2(dir.x, dir.z)


func _has_los(player: Node3D) -> bool:
	var space := get_world_3d().direct_space_state
	if space == null:
		return true
	var from := global_position + Vector3(0.0, LOS_EYE, 0.0)
	var to := player.global_position + Vector3(0.0, LOS_EYE, 0.0)
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = 1
	q.exclude = [get_rid()]
	var hit := space.intersect_ray(q)
	return hit.is_empty()


func _attack_hold() -> float:
	var resolved := _resolve(CLIP_ATTACK)
	if _ap and resolved != "" and _ap.has_animation(resolved):
		var anim := _ap.get_animation(resolved)
		if anim and anim.length > 0.05:
			return anim.length
	return telegraph_time if telegraph_time > 0.05 else ATTACK_CLIP_FALLBACK


func _keep_anim(logical: String) -> void:
	var resolved := _resolve(logical)
	if resolved == "":
		return
	if _ap and _ap.current_animation != resolved:
		_ap.play(resolved)


func _play_clip(logical: String) -> void:
	var resolved := _resolve(logical)
	if resolved == "" or _ap == null:
		return
	_ap.play(resolved)


func _resolve(logical: String) -> String:
	return str(_clips.get(logical, logical))


func _play_growl(kind: String) -> void:
	if _snd == null:
		return
	var stream: AudioStream = _growls.get(kind, null)
	if stream == null:
		return
	_snd.stream = stream
	_snd.play()


func _load_growls() -> void:
	_growls = {
		"idle": load("res://audio/ashwight_idle.wav"),
		"chase": load("res://audio/ashwight_chase.wav"),
		"attack": load("res://audio/deamon_attack2.wav"),
		"pain": load("res://audio/ashwight_pain.wav"),
		"death": load("res://audio/ashwight_death.wav"),
	}
	if _growls["attack"] == null:
		_growls["attack"] = load("res://audio/ashwight_attack.wav")
	if _growls["idle"] == null:
		_growls["idle"] = load("res://audio/demon_growl.wav")


func _maybe_first_see(player: Node3D) -> void:
	if _first_seen or _dead:
		return
	if not _has_los(player):
		return
	var cam: Camera3D = player.get_look_camera() if player.has_method("get_look_camera") else null
	if cam == null:
		return
	var to := (global_position + Vector3(0.0, 1.20, 0.0)) - cam.global_position
	if to.length() > 14.0:
		return
	var facing := -cam.global_transform.basis.z
	if facing.dot(to.normalized()) < 0.38:
		return
	_first_seen = true
	if _snd == null or _see_growl == null:
		return
	_snd.stream = _see_growl
	_snd.play()


func _spawn_body_splat(pos: Vector3, nrm: Vector3) -> void:
	var mi := MeshInstance3D.new()
	mi.name = "BodySplat"
	var q := QuadMesh.new()
	q.size = Vector2(0.16, 0.16)
	mi.mesh = q
	var src: Material = load("res://materials/mat_blood.tres")
	var mat: StandardMaterial3D
	if src is StandardMaterial3D:
		mat = (src as StandardMaterial3D).duplicate() as StandardMaterial3D
	else:
		mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.08, 0.03, 0.88)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = false
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = mat
	add_child(mi)
	mi.global_position = pos + nrm.normalized() * 0.012
	var up := nrm.normalized() if nrm.length() > 0.01 else Vector3.UP
	var tmp := Vector3.RIGHT if absf(up.dot(Vector3.UP)) > 0.92 else Vector3.UP
	var xaxis := up.cross(tmp).normalized()
	var yaxis := xaxis.cross(up).normalized()
	mi.global_transform.basis = Basis(xaxis, yaxis, up)
	var tw := create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.72)
	tw.tween_callback(mi.queue_free)


func _spawn_spray(pos: Vector3, nrm: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.name = "EmberBlood"
	p.amount = 20
	p.lifetime = 0.55
	p.one_shot = true
	p.explosiveness = 0.94
	p.emitting = false
	p.direction = nrm.normalized() if nrm.length() > 0.01 else Vector3.UP
	p.spread = 48.0
	p.initial_velocity_min = 1.1
	p.initial_velocity_max = 3.2
	p.gravity = Vector3(0, -5.5, 0)
	p.scale_amount_min = 0.03
	p.scale_amount_max = 0.07
	var qm := QuadMesh.new()
	qm.size = Vector2(0.07, 0.07)
	p.mesh = qm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.08, 0.03, 0.88)
	mat.albedo_texture = load("res://textures/tex_blood.png")
	mat.emission_enabled = true
	mat.emission = Color(0.85, 0.22, 0.04)
	mat.emission_energy_multiplier = EMISSION_CAP
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	p.material_override = mat
	var host: Node = get_parent()
	if host == null:
		host = self
	host.add_child(p)
	p.global_position = pos
	p.emitting = true
	var tw := create_tween()
	tw.tween_interval(0.55)
	tw.tween_callback(p.queue_free)


func _instance_visual() -> void:
	if FileAccess.file_exists(GLB_PATH) or ResourceLoader.exists(GLB_PATH):
		var packed := load(GLB_PATH) as PackedScene
		if packed:
			_visual = packed.instantiate() as Node3D
	if _visual:
		_visual.name = "EmberDemon"
		_visual.scale = Vector3(VISUAL_SCALE, VISUAL_SCALE, VISUAL_SCALE)
		add_child(_visual)
		_ap = _find_anim_player(_visual)
		if _ap:
			_clip_names = _ap.get_animation_list()
			print("EMBER_CLIPS ", ", ".join(_clip_names))
			_bind_clips()
		_cap_emission(_visual)
		return
	print("EMBER_SOFTFAIL ember_demon.glb missing — placeholder mesh at DemonSpot_Reception")
	_build_placeholder()


func _build_placeholder() -> void:
	_visual = Node3D.new()
	_visual.name = "EmberPlaceholder"
	add_child(_visual)
	var ember_tex := "res://textures/hero/tex-ashwight-ember.png"
	var crust := _mat(ember_tex, Color(0.18, 0.05, 0.03), 0.72, 0.28)
	var glow := _mat(ember_tex, Color(0.95, 0.35, 0.08), 0.42, EMISSION_CAP)
	var horn := _mat("", Color(0.08, 0.04, 0.03), 0.55, 0.0)
	_box(_visual, "Torso", Vector3(0.46, 0.72, 0.32), Vector3(0.0, 0.95, 0.04), crust)
	_box(_visual, "ChestGlow", Vector3(0.22, 0.28, 0.10), Vector3(0.0, 1.02, 0.16), glow)
	_box(_visual, "Pelvis", Vector3(0.40, 0.28, 0.28), Vector3(0.0, 0.52, 0.02), crust)
	_box(_visual, "Head", Vector3(0.26, 0.28, 0.24), Vector3(0.0, 1.48, 0.06), crust)
	_box(_visual, "HornL", Vector3(0.07, 0.28, 0.07), Vector3(-0.12, 1.70, -0.02), horn, Vector3(18, 0, -22))
	_box(_visual, "HornR", Vector3(0.07, 0.28, 0.07), Vector3(0.12, 1.70, -0.02), horn, Vector3(18, 0, 22))
	_box(_visual, "ArmL", Vector3(0.12, 0.52, 0.12), Vector3(-0.32, 0.88, 0.04), crust, Vector3(8, 0, 16))
	_box(_visual, "ArmR", Vector3(0.12, 0.52, 0.12), Vector3(0.32, 0.88, 0.04), crust, Vector3(8, 0, -16))
	_box(_visual, "LegL", Vector3(0.14, 0.52, 0.16), Vector3(-0.12, 0.26, 0.02), crust)
	_box(_visual, "LegR", Vector3(0.14, 0.52, 0.16), Vector3(0.12, 0.26, 0.02), crust)
	# Bat wings — 1.7 m silhouette, folded slightly back.
	_box(_visual, "WingL", Vector3(0.08, 0.85, 0.95), Vector3(-0.42, 1.15, -0.22), crust, Vector3(12, 28, 18))
	_box(_visual, "WingR", Vector3(0.08, 0.85, 0.95), Vector3(0.42, 1.15, -0.22), crust, Vector3(12, -28, -18))
	_box(_visual, "WingGlowL", Vector3(0.03, 0.40, 0.55), Vector3(-0.46, 1.10, -0.18), glow, Vector3(12, 28, 18))
	_box(_visual, "WingGlowR", Vector3(0.03, 0.40, 0.55), Vector3(0.46, 1.10, -0.18), glow, Vector3(12, -28, -18))


func _mat(tex_path: String, color: Color, rough: float, emit: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	if tex_path != "" and (FileAccess.file_exists(tex_path) or ResourceLoader.exists(tex_path)):
		m.albedo_texture = load(tex_path)
	m.roughness = rough
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = color
		if m.albedo_texture:
			m.emission_texture = m.albedo_texture
		m.emission_energy_multiplier = minf(emit, EMISSION_CAP)
	return m


func _box(parent: Node, name: String, size: Vector3, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> void:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = mat
	parent.add_child(mi)


func _find_anim_player(n: Node) -> AnimationPlayer:
	var with_idle: AnimationPlayer = null
	var first: AnimationPlayer = null
	var stack: Array[Node] = [n]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is AnimationPlayer:
			var ap := cur as AnimationPlayer
			if first == null:
				first = ap
			if _list_has(ap.get_animation_list(), CLIP_IDLE):
				with_idle = ap
				break
		for c in cur.get_children():
			stack.append(c)
	return with_idle if with_idle else first


func _list_has(names: PackedStringArray, want: String) -> bool:
	for n in names:
		if n == want or String(n).ends_with("/" + want) or String(n).ends_with("|" + want):
			return true
	return false


func _bind_clips() -> void:
	_clips = {
		CLIP_IDLE: _match_clip(CLIP_IDLE),
		CLIP_CHASE: _match_clip(CLIP_CHASE),
		CLIP_ATTACK: _match_clip(CLIP_ATTACK),
		CLIP_DEATH: _match_clip(CLIP_DEATH),
		CLIP_HIT: _match_clip(CLIP_HIT),
	}
	_set_loop(_clips[CLIP_IDLE], true)
	_set_loop(_clips[CLIP_CHASE], true)
	_set_loop(_clips[CLIP_ATTACK], false)
	_set_loop(_clips[CLIP_DEATH], false)
	_set_loop(_clips[CLIP_HIT], false)


func _match_clip(want: String) -> String:
	if _ap == null:
		return want
	if _ap.has_animation(want):
		return want
	for n in _clip_names:
		var s := String(n)
		if s == want or s.ends_with("/" + want) or s.ends_with("|" + want) or s.get_file() == want:
			return s
	return want


func _set_loop(clip_name: String, loop: bool) -> void:
	if _ap == null or clip_name == "" or not _ap.has_animation(clip_name):
		return
	var anim := _ap.get_animation(clip_name)
	if anim == null:
		return
	anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE


func _cap_emission(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var mesh := mi.mesh
		var surfaces := 0
		if mesh:
			surfaces = mesh.get_surface_count()
		for i in maxi(surfaces, mi.get_surface_override_material_count()):
			var mat := mi.get_active_material(i)
			if mat == null and mesh and i < surfaces:
				mat = mesh.surface_get_material(i)
			if mat is StandardMaterial3D:
				var sm := mat as StandardMaterial3D
				if sm.emission_enabled and sm.emission_energy_multiplier > EMISSION_CAP:
					var dup := sm.duplicate() as StandardMaterial3D
					dup.emission_energy_multiplier = EMISSION_CAP
					mi.set_surface_override_material(i, dup)
	for c in n.get_children():
		_cap_emission(c)
