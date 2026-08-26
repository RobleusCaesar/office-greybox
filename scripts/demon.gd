extends CharacterBody3D
## Ashwight — gaunt ashen/ember biped. Digitigrade, vertical split jaw,
## one swollen shoulder, named bones. 3–5 shotgun shells to drop.

enum State { IDLE, CHASE, TELEGRAPH, RECOVER, DEAD }

@export var max_hp: float = 120.0
@export var move_speed: float = 3.15
@export var attack_damage: float = 18.0
@export var attack_range: float = 1.55
@export var aggro_range: float = 7.0
@export var telegraph_time: float = 0.52
@export var recover_time: float = 0.72

var hp: float = 120.0
var state: State = State.IDLE

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _timer: float = 0.0
var _rig: Node3D
var _ap: AnimationPlayer
var _snd: AudioStreamPlayer3D
var _dead: bool = false
var _shot_gate: float = 0.0
var _ember_mat: StandardMaterial3D
var _growls: Dictionary = {}


func _ready() -> void:
	hp = max_hp
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("enemies")
	_build_ashwight()
	_build_anims()
	_load_growls()
	_snd = AudioStreamPlayer3D.new()
	_snd.volume_db = -2.0
	_snd.max_distance = 18.0
	add_child(_snd)
	_play_growl("idle")
	_ap.play("idle")


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
		_blood(hit_pos, hit_normal)
	else:
		_blood(global_position + Vector3(0, 1.15, 0), Vector3.UP)
	_play_growl("pain")
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
	if _ap:
		_ap.play("death")
	var tw := create_tween()
	tw.tween_interval(1.35)
	tw.tween_callback(queue_free)


func _physics_process(delta: float) -> void:
	_shot_gate = maxf(0.0, _shot_gate - delta)
	if _ember_mat:
		_ember_mat.emission_energy_multiplier = 1.55 + 0.45 * sin(Time.get_ticks_msec() * 0.004)
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
			_keep_anim("idle")
			if dist <= aggro_range:
				state = State.CHASE
				_play_growl("chase")
		State.CHASE:
			_keep_anim("lurch")
			if dir != Vector3.ZERO:
				look_at(global_position + dir, Vector3.UP)
			if dist <= attack_range:
				state = State.TELEGRAPH
				_timer = telegraph_time
				velocity.x = 0.0
				velocity.z = 0.0
				_ap.play("attack")
				_play_growl("attack")
			else:
				velocity.x = dir.x * move_speed
				velocity.z = dir.z * move_speed
		State.TELEGRAPH:
			_timer -= delta
			velocity.x = 0.0
			velocity.z = 0.0
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


func _keep_anim(n: String) -> void:
	if _ap and _ap.current_animation != n:
		_ap.play(n)


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
		"attack": load("res://audio/ashwight_attack.wav"),
		"pain": load("res://audio/ashwight_pain.wav"),
		"death": load("res://audio/ashwight_death.wav"),
	}
	if _growls["idle"] == null:
		_growls["idle"] = load("res://audio/demon_growl.wav")


func _blood(pos: Vector3, nrm: Vector3) -> void:
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
	get_parent().add_child(p)
	p.global_position = pos
	p.emitting = true
	var tw := create_tween()
	tw.tween_interval(0.9)
	tw.tween_callback(p.queue_free)


func _mat_ember() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.12, 0.08, 0.07)
	m.albedo_texture = load("res://textures/hero/tex-ashwight-ember.png")
	m.emission_enabled = true
	m.emission = Color(0.85, 0.22, 0.05)
	m.emission_texture = load("res://textures/hero/tex-ashwight-emit.png")
	m.emission_energy_multiplier = 1.7
	m.roughness = 0.82
	m.metallic = 0.04
	m.uv1_scale = Vector3(2.2, 2.2, 2.2)
	_ember_mat = m
	return m


func _mat_bone() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.18, 0.14, 0.11)
	m.roughness = 0.7
	return m


func _mat_eye() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.9, 0.08, 0.04)
	m.emission_enabled = true
	m.emission = Color(1.0, 0.12, 0.04)
	m.emission_energy_multiplier = 4.2
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _mat_maw() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.28, 0.05, 0.04)
	m.emission_enabled = true
	m.emission = Color(0.55, 0.08, 0.04)
	m.emission_energy_multiplier = 1.3
	m.roughness = 0.55
	return m


func _cap(parent: Node3D, name: String, r: float, h: float, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CapsuleMesh.new()
	mesh.radius = r
	mesh.height = h
	mesh.radial_segments = 10
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _sph(parent: Node3D, name: String, r: float, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 12
	mesh.rings = 8
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _cyl(parent: Node3D, name: String, r0: float, r1: float, h: float, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = r0
	mesh.bottom_radius = r1
	mesh.height = h
	mesh.radial_segments = 10
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _bone(parent: Node3D, name: String, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.name = name
	n.position = pos
	parent.add_child(n)
	return n


func _build_ashwight() -> void:
	_rig = Node3D.new()
	_rig.name = "Rig"
	add_child(_rig)
	var hide := _mat_ember()
	var bone := _mat_bone()
	var eye := _mat_eye()
	var maw := _mat_maw()

	# ~2 m hunched. Pelvis high, spine folds forward.
	var pelvis := _bone(_rig, "Pelvis", Vector3(0, 1.08, 0.04))
	_sph(pelvis, "Mesh", 0.12, Vector3.ZERO, hide)

	var spine := _bone(pelvis, "Spine", Vector3(0, 0.16, -0.02))
	_cap(spine, "Mesh", 0.09, 0.28, Vector3(0, 0.08, 0), hide)

	var chest := _bone(spine, "Chest", Vector3(0, 0.26, 0.02))
	_sph(chest, "Cage", 0.20, Vector3(0, 0.06, 0.02), hide)
	for i in 5:
		var ang := deg_to_rad(-30 + i * 14)
		_cyl(chest, "Rib_%d" % i, 0.012, 0.01, 0.22, Vector3(0.0, 0.08 - i * 0.04, 0.08), hide, Vector3(0, 0, 90))
		chest.get_node("Rib_%d" % i).rotation.y = ang * 0.15
	_cyl(chest, "Sternum", 0.02, 0.016, 0.22, Vector3(0, 0.02, 0.12), hide)

	# Swollen LEFT shoulder (creature's left = -X in Godot after look_at).
	# Concept: viewer's right = creature left. Keep it visually dominant.
	var shoulder_l := _bone(chest, "ShoulderL", Vector3(-0.22, 0.18, 0.02))
	_sph(shoulder_l, "MassA", 0.16, Vector3(-0.04, 0.08, 0.0), hide)
	_sph(shoulder_l, "MassB", 0.12, Vector3(-0.08, 0.16, 0.04), hide)
	_sph(shoulder_l, "MassC", 0.09, Vector3(0.02, 0.14, -0.04), hide)
	_cyl(shoulder_l, "Vault", 0.11, 0.07, 0.18, Vector3(-0.02, 0.12, 0.0), hide)

	var shoulder_r := _bone(chest, "ShoulderR", Vector3(0.18, 0.10, 0.0))
	_sph(shoulder_r, "Mesh", 0.07, Vector3.ZERO, hide)

	var uarm_l := _bone(shoulder_l, "UpperArmL", Vector3(-0.10, -0.06, 0.0))
	_cap(uarm_l, "Mesh", 0.045, 0.42, Vector3(0, -0.16, 0), hide)
	var farm_l := _bone(uarm_l, "ForeArmL", Vector3(0, -0.34, 0))
	_cap(farm_l, "Mesh", 0.035, 0.38, Vector3(0, -0.16, 0), hide)
	var hand_l := _bone(farm_l, "HandL", Vector3(0, -0.34, 0))
	_sph(hand_l, "Palm", 0.045, Vector3.ZERO, hide)
	for i in 3:
		_cyl(hand_l, "Claw_%d" % i, 0.01, 0.004, 0.12, Vector3(-0.03 + i * 0.03, -0.08, 0.02), bone, Vector3(20, 0, 0))

	var uarm_r := _bone(shoulder_r, "UpperArmR", Vector3(0.08, -0.04, 0))
	_cap(uarm_r, "Mesh", 0.038, 0.40, Vector3(0, -0.16, 0), hide)
	var farm_r := _bone(uarm_r, "ForeArmR", Vector3(0, -0.32, 0))
	_cap(farm_r, "Mesh", 0.032, 0.36, Vector3(0, -0.16, 0), hide)
	var hand_r := _bone(farm_r, "HandR", Vector3(0, -0.32, 0))
	_sph(hand_r, "Palm", 0.04, Vector3.ZERO, hide)
	for i in 3:
		_cyl(hand_r, "Claw_%d" % i, 0.01, 0.004, 0.12, Vector3(-0.03 + i * 0.03, -0.08, 0.02), bone, Vector3(20, 0, 0))

	var neck := _bone(chest, "Neck", Vector3(0.04, 0.22, 0.06))
	_cap(neck, "Mesh", 0.05, 0.14, Vector3(0, 0.04, 0.02), hide, Vector3(18, 0, 0))

	var head := _bone(neck, "Head", Vector3(0.0, 0.12, 0.08))
	_sph(head, "Skull", 0.13, Vector3(0, 0.02, 0.0), hide)
	_cyl(head, "Cranium", 0.11, 0.09, 0.12, Vector3(0, 0.06, -0.01), hide)
	_sph(head, "EyeL", 0.018, Vector3(-0.04, 0.03, 0.10), eye)
	_sph(head, "EyeR", 0.018, Vector3(0.04, 0.03, 0.10), eye)
	_cyl(head, "NubL", 0.016, 0.008, 0.06, Vector3(-0.05, 0.14, -0.01), bone)
	_cyl(head, "NubR", 0.016, 0.008, 0.06, Vector3(0.05, 0.14, -0.01), bone)

	# Vertical split jaw — two mandibles that open sideways.
	var jaw_l := _bone(head, "JawL", Vector3(-0.02, -0.04, 0.04))
	_cyl(jaw_l, "Mandible", 0.03, 0.018, 0.16, Vector3(-0.02, -0.05, 0.06), hide, Vector3(70, -18, 0))
	_cyl(jaw_l, "Flesh", 0.02, 0.012, 0.10, Vector3(-0.01, -0.03, 0.05), maw, Vector3(70, -18, 0))
	var jaw_r := _bone(head, "JawR", Vector3(0.02, -0.04, 0.04))
	_cyl(jaw_r, "Mandible", 0.03, 0.018, 0.16, Vector3(0.02, -0.05, 0.06), hide, Vector3(70, 18, 0))
	_cyl(jaw_r, "Flesh", 0.02, 0.012, 0.10, Vector3(0.01, -0.03, 0.05), maw, Vector3(70, 18, 0))

	# Digitigrade legs.
	_digit_leg(pelvis, "L", Vector3(-0.11, -0.06, 0.02), hide, bone)
	_digit_leg(pelvis, "R", Vector3(0.11, -0.06, 0.02), hide, bone)


func _digit_leg(pelvis: Node3D, side: String, pos: Vector3, hide: Material, bone: Material) -> void:
	var thigh := _bone(pelvis, "Thigh" + side, pos)
	_cap(thigh, "Mesh", 0.055, 0.36, Vector3(0, -0.14, 0.02), hide, Vector3(12, 0, 0))
	var shin := _bone(thigh, "Shin" + side, Vector3(0, -0.30, 0.04))
	_cap(shin, "Mesh", 0.042, 0.32, Vector3(0, -0.12, -0.02), hide, Vector3(-18, 0, 0))
	var tarsus := _bone(shin, "Tarsus" + side, Vector3(0, -0.26, -0.04))
	_cap(tarsus, "Mesh", 0.032, 0.28, Vector3(0, -0.08, 0.08), hide, Vector3(55, 0, 0))
	var foot := _bone(tarsus, "Foot" + side, Vector3(0, -0.10, 0.14))
	_sph(foot, "Pad", 0.04, Vector3.ZERO, hide)
	for i in 3:
		_cyl(foot, "Toe_%d" % i, 0.012, 0.006, 0.09, Vector3(-0.03 + i * 0.03, -0.01, 0.05), bone, Vector3(80, 0, 0))
	_cyl(foot, "Spur", 0.01, 0.005, 0.07, Vector3(0, 0.01, -0.04), bone, Vector3(-40, 0, 0))


func _anim(name: String, length: float, loop: bool) -> Animation:
	var a := Animation.new()
	a.length = length
	a.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	return a


func _track(a: Animation, path: String, keys: Array) -> void:
	var i := a.add_track(Animation.TYPE_VALUE)
	a.track_set_path(i, NodePath(path))
	for k in keys:
		a.track_insert_key(i, k[0], k[1])


func _build_anims() -> void:
	_ap = AnimationPlayer.new()
	_ap.name = "AnimationPlayer"
	add_child(_ap)
	var lib := AnimationLibrary.new()

	var idle := _anim("idle", 1.6, true)
	_track(idle, "Rig/Pelvis/Spine/Chest/Neck/Head:rotation_degrees", [[0.0, Vector3(8, 0, 0)], [0.8, Vector3(4, 7, 0)], [1.6, Vector3(8, 0, 0)]])
	_track(idle, "Rig/Pelvis/Spine/Chest/Neck/Head/JawL:rotation_degrees", [[0.0, Vector3.ZERO], [0.5, Vector3(0, -10, 0)], [1.6, Vector3.ZERO]])
	_track(idle, "Rig/Pelvis/Spine/Chest/Neck/Head/JawR:rotation_degrees", [[0.0, Vector3.ZERO], [0.5, Vector3(0, 10, 0)], [1.6, Vector3.ZERO]])
	_track(idle, "Rig/Pelvis:position", [[0.0, Vector3(0, 1.08, 0.04)], [0.8, Vector3(0, 1.10, 0.04)], [1.6, Vector3(0, 1.08, 0.04)]])
	_track(idle, "Rig/Pelvis/Spine/Chest/ShoulderL:rotation_degrees", [[0.0, Vector3.ZERO], [0.8, Vector3(4, 0, -4)], [1.6, Vector3.ZERO]])
	lib.add_animation("idle", idle)

	var lurch := _anim("lurch", 0.72, true)
	_track(lurch, "Rig/Pelvis/ThighL:rotation_degrees", [[0.0, Vector3(26, 0, 0)], [0.36, Vector3(-22, 0, 0)], [0.72, Vector3(26, 0, 0)]])
	_track(lurch, "Rig/Pelvis/ThighR:rotation_degrees", [[0.0, Vector3(-22, 0, 0)], [0.36, Vector3(26, 0, 0)], [0.72, Vector3(-22, 0, 0)]])
	_track(lurch, "Rig/Pelvis/ThighL/ShinL:rotation_degrees", [[0.0, Vector3(-18, 0, 0)], [0.36, Vector3(12, 0, 0)], [0.72, Vector3(-18, 0, 0)]])
	_track(lurch, "Rig/Pelvis/ThighR/ShinR:rotation_degrees", [[0.0, Vector3(12, 0, 0)], [0.36, Vector3(-18, 0, 0)], [0.72, Vector3(12, 0, 0)]])
	_track(lurch, "Rig/Pelvis/ThighL/ShinL/TarsusL:rotation_degrees", [[0.0, Vector3(10, 0, 0)], [0.36, Vector3(-8, 0, 0)], [0.72, Vector3(10, 0, 0)]])
	_track(lurch, "Rig/Pelvis/ThighR/ShinR/TarsusR:rotation_degrees", [[0.0, Vector3(-8, 0, 0)], [0.36, Vector3(10, 0, 0)], [0.72, Vector3(-8, 0, 0)]])
	_track(lurch, "Rig/Pelvis/Spine/Chest/ShoulderL/UpperArmL:rotation_degrees", [[0.0, Vector3(-16, 0, 8)], [0.36, Vector3(18, 0, 8)], [0.72, Vector3(-16, 0, 8)]])
	_track(lurch, "Rig/Pelvis/Spine/Chest/ShoulderR/UpperArmR:rotation_degrees", [[0.0, Vector3(18, 0, -8)], [0.36, Vector3(-16, 0, -8)], [0.72, Vector3(18, 0, -8)]])
	_track(lurch, "Rig/Pelvis:position", [[0.0, Vector3(0, 1.08, 0.04)], [0.36, Vector3(0, 1.16, 0.04)], [0.72, Vector3(0, 1.08, 0.04)]])
	lib.add_animation("lurch", lurch)

	var attack := _anim("attack", 0.55, false)
	_track(attack, "Rig/Pelvis/Spine/Chest/ShoulderL/UpperArmL:rotation_degrees", [[0.0, Vector3(-70, 0, 12)], [0.22, Vector3(48, 0, 10)], [0.55, Vector3.ZERO]])
	_track(attack, "Rig/Pelvis/Spine/Chest/ShoulderR/UpperArmR:rotation_degrees", [[0.0, Vector3(-70, 0, -12)], [0.22, Vector3(48, 0, -10)], [0.55, Vector3.ZERO]])
	_track(attack, "Rig/Pelvis/Spine/Chest:position", [[0.0, Vector3(0, 0.26, 0.02)], [0.22, Vector3(0, 0.26, 0.20)], [0.55, Vector3(0, 0.26, 0.02)]])
	_track(attack, "Rig/Pelvis/Spine/Chest/Neck/Head/JawL:rotation_degrees", [[0.0, Vector3.ZERO], [0.18, Vector3(0, -38, 12)], [0.55, Vector3.ZERO]])
	_track(attack, "Rig/Pelvis/Spine/Chest/Neck/Head/JawR:rotation_degrees", [[0.0, Vector3.ZERO], [0.18, Vector3(0, 38, -12)], [0.55, Vector3.ZERO]])
	lib.add_animation("attack", attack)

	var death := _anim("death", 1.2, false)
	_track(death, "Rig:rotation_degrees", [[0.0, Vector3.ZERO], [0.8, Vector3(78, 8, 14)]])
	_track(death, "Rig:position", [[0.0, Vector3.ZERO], [0.8, Vector3(0, 0.12, 0.38)]])
	_track(death, "Rig/Pelvis/Spine/Chest/Neck/Head/JawL:rotation_degrees", [[0.0, Vector3.ZERO], [0.5, Vector3(0, -22, 0)]])
	_track(death, "Rig/Pelvis/Spine/Chest/Neck/Head/JawR:rotation_degrees", [[0.0, Vector3.ZERO], [0.5, Vector3(0, 22, 0)]])
	lib.add_animation("death", death)

	_ap.add_animation_library("", lib)
