extends CharacterBody3D
## Abyssal Stalker — Meshy GLB at DemonSpot_01.
## Instances models/abyssal_stalker.glb and plays the imported Mixamo clips.
## No runtime capsule / Ashwight Pelvis-Jaw builder.

enum State { IDLE, CHASE, TELEGRAPH, RECOVER, DEAD }

const GLB_PATH := "res://models/abyssal_stalker.glb"

const CLIP_IDLE := "Idle_8"
const CLIP_CHASE := "Walking"
const CLIP_ATTACK := "Axe_Spin_Attack"
const CLIP_DEATH := "Shot_and_Fall_Forward"

const ATTACK_CLIP_FALLBACK := 2.50
const VISUAL_SCALE := 1.0
const MATERIAL_1_EMISSION := 0.32
const LOS_EYE := 1.45

@export var max_hp: float = 120.0
@export var move_speed: float = 3.15
@export var attack_damage: float = 18.0
@export var attack_range: float = 1.55
@export var aggro_range: float = 7.0
@export var telegraph_time: float = 2.50
@export var recover_time: float = 0.72

var hp: float = 120.0
var state: State = State.IDLE

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _timer: float = 0.0
var _visual: Node3D
var _ap: AnimationPlayer
var _snd: AudioStreamPlayer3D
var _dead: bool = false
var _shot_gate: float = 0.0
var _growls: Dictionary = {}
var _clips: Dictionary = {}
var _clip_names: PackedStringArray = PackedStringArray()
var _ambush: bool = true
var _revealed: bool = false
var _scare: AudioStream


func _ready() -> void:
	hp = max_hp
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("enemies")
	_instance_glb()
	_load_growls()
	_scare = load("res://audio/deamon_attack.mp3")
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
	# Collapse multi-pellet frames into one shell (~24–32). Direct hits pass through.
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
	_reveal()
	if state == State.IDLE:
		state = State.CHASE
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
	# Corpse stays in the cubicle.


func _physics_process(delta: float) -> void:
	_shot_gate = maxf(0.0, _shot_gate - delta)
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

	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()
	var dir := to_player.normalized() if dist > 0.01 else Vector3.ZERO

	match state:
		State.IDLE:
			velocity.x = 0.0
			velocity.z = 0.0
			_keep_anim(CLIP_IDLE)
			if _player_committed_to_cubicle(player):
				_reveal()
				state = State.CHASE
			elif (not _ambush) and dist <= aggro_range and _has_los(player):
				state = State.CHASE
				_play_growl("chase")
		State.CHASE:
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
	# Export faces +Z. Do not use look_at (−Z forward).
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


func _player_committed_to_cubicle(player: Node3D) -> bool:
	var p := player.global_position
	return p.x > 7.55 and p.x < 10.95 and p.z < 10.22 and p.z > 7.75


func _reveal() -> void:
	if _revealed:
		return
	_revealed = true
	_ambush = false
	if _snd == null or _scare == null:
		return
	_snd.stream = _scare
	_snd.play()


func _spawn_body_splat(pos: Vector3, nrm: Vector3) -> void:
	# Parent to the demon so it rides the mesh — fade/free at 0.72s so it cannot hang in air.
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
	mat.albedo_color = Color(0.42, 0.05, 0.03, 0.88)
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
	p.name = "AshBlood"
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
	mat.albedo_color = Color(0.42, 0.05, 0.03, 0.88)
	mat.albedo_texture = load("res://textures/tex_blood.png")
	mat.emission_enabled = true
	mat.emission = Color(0.75, 0.16, 0.04)
	mat.emission_energy_multiplier = 1.8
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


func _instance_glb() -> void:
	# load() only — packed-res FileAccess probes lie on HTML5.
	var packed := load(GLB_PATH) as PackedScene
	if packed == null:
		push_error("BLOCKED: missing abyssal_stalker.glb")
		print("BLOCKED: missing abyssal_stalker.glb")
		return
	_visual = packed.instantiate() as Node3D
	if _visual == null:
		push_error("BLOCKED: abyssal_stalker.glb is not a scene")
		print("BLOCKED: abyssal_stalker.glb is not a scene")
		return
	_visual.name = "AbyssalStalker"
	# Person-sized export. Armature scale 0.01 is already in the GLB.
	# Do not 100× upscale — Mixamo bind AABB looks like 1.7 cm.
	_visual.scale = Vector3(VISUAL_SCALE, VISUAL_SCALE, VISUAL_SCALE)
	add_child(_visual)
	_ap = _find_anim_player(_visual)
	if _ap == null:
		push_error("Abyssal Stalker GLB has no AnimationPlayer")
		print("STALKER_CLIPS ")
		_tone_material_1(_visual)
		return
	_clip_names = _ap.get_animation_list()
	print("STALKER_CLIPS ", ", ".join(_clip_names))
	_bind_clips()
	_tone_material_1(_visual)


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
	}
	_set_loop(_clips[CLIP_IDLE], true)
	_set_loop(_clips[CLIP_CHASE], true)
	_set_loop(_clips[CLIP_ATTACK], false)
	_set_loop(_clips[CLIP_DEATH], false)


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


func _tone_material_1(n: Node) -> void:
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
				var nm := sm.resource_name
				if nm == "Material_1" or nm.ends_with("Material_1"):
					var dup := sm.duplicate() as StandardMaterial3D
					dup.emission_enabled = true
					if dup.emission_texture == null and dup.albedo_texture:
						dup.emission_texture = dup.albedo_texture
					dup.emission_energy_multiplier = MATERIAL_1_EMISSION
					mi.set_surface_override_material(i, dup)
	for c in n.get_children():
		_tone_material_1(c)
