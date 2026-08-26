extends CharacterBody3D
## One bipedal cubicle demon. AnimationPlayer snarl / move / attack / death.
## 3–5 shotgun shells to drop.

enum State { IDLE, CHASE, TELEGRAPH, RECOVER, DEAD }

@export var max_hp: float = 100.0
@export var move_speed: float = 3.15
@export var attack_damage: float = 18.0
@export var attack_range: float = 1.55
@export var aggro_range: float = 7.0
@export var telegraph_time: float = 0.52
@export var recover_time: float = 0.72

var hp: float = 100.0
var state: State = State.IDLE

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _timer: float = 0.0
var _rig: Node3D
var _ap: AnimationPlayer
var _snd: AudioStreamPlayer3D
var _dead: bool = false
var _shot_gate: float = 0.0


func _ready() -> void:
	hp = max_hp
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("enemies")
	_build_biped()
	_build_anims()
	_snd = AudioStreamPlayer3D.new()
	_snd.stream = load("res://audio/demon_growl.wav")
	_snd.volume_db = -2.0
	_snd.max_distance = 18.0
	add_child(_snd)
	_ap.play("snarl")


func take_damage(amount: float) -> void:
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
	if _ap:
		_ap.play("death")
	var tw := create_tween()
	tw.tween_interval(1.15)
	tw.tween_callback(queue_free)


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
			_keep_anim("snarl")
			if dist <= aggro_range:
				state = State.CHASE
				if _snd:
					_snd.play()
		State.CHASE:
			_keep_anim("move")
			if dir != Vector3.ZERO:
				look_at(global_position + dir, Vector3.UP)
			if dist <= attack_range:
				state = State.TELEGRAPH
				_timer = telegraph_time
				velocity.x = 0.0
				velocity.z = 0.0
				_ap.play("attack")
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


func _part(parent: Node3D, name: String, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	parent.add_child(mi)
	return mi


func _build_biped() -> void:
	_rig = Node3D.new()
	_rig.name = "Rig"
	add_child(_rig)
	var hide := StandardMaterial3D.new()
	hide.albedo_color = Color(0.22, 0.04, 0.04)
	hide.emission_enabled = true
	hide.emission = Color(0.7, 0.1, 0.04)
	hide.emission_energy_multiplier = 1.3
	hide.roughness = 0.65
	var horn := StandardMaterial3D.new()
	horn.albedo_color = Color(0.08, 0.06, 0.05)
	var eye := StandardMaterial3D.new()
	eye.albedo_color = Color(1.0, 0.25, 0.05)
	eye.emission_enabled = true
	eye.emission = Color(1.0, 0.3, 0.05)
	eye.emission_energy_multiplier = 3.0

	var pelvis := Node3D.new()
	pelvis.name = "Pelvis"
	pelvis.position = Vector3(0, 0.95, 0)
	_rig.add_child(pelvis)
	_part(pelvis, "Mesh", Vector3(0.38, 0.22, 0.22), Vector3.ZERO, hide)

	var torso := Node3D.new()
	torso.name = "Torso"
	torso.position = Vector3(0, 0.28, 0)
	pelvis.add_child(torso)
	_part(torso, "Mesh", Vector3(0.48, 0.55, 0.28), Vector3.ZERO, hide)

	var head := Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 0.42, 0.04)
	torso.add_child(head)
	_part(head, "Mesh", Vector3(0.28, 0.28, 0.26), Vector3.ZERO, hide)
	_part(head, "HornL", Vector3(0.06, 0.28, 0.06), Vector3(-0.1, 0.22, 0.0), horn)
	_part(head, "HornR", Vector3(0.06, 0.28, 0.06), Vector3(0.1, 0.22, 0.0), horn)
	_part(head, "EyeL", Vector3(0.07, 0.05, 0.05), Vector3(-0.07, 0.04, 0.13), eye)
	_part(head, "EyeR", Vector3(0.07, 0.05, 0.05), Vector3(0.07, 0.04, 0.13), eye)

	var jaw := Node3D.new()
	jaw.name = "Jaw"
	jaw.position = Vector3(0, -0.1, 0.06)
	head.add_child(jaw)
	_part(jaw, "Mesh", Vector3(0.22, 0.08, 0.16), Vector3.ZERO, hide)

	var arml := Node3D.new()
	arml.name = "ArmL"
	arml.position = Vector3(-0.32, 0.18, 0)
	torso.add_child(arml)
	_part(arml, "Mesh", Vector3(0.12, 0.55, 0.12), Vector3(0, -0.22, 0), hide)

	var armr := Node3D.new()
	armr.name = "ArmR"
	armr.position = Vector3(0.32, 0.18, 0)
	torso.add_child(armr)
	_part(armr, "Mesh", Vector3(0.12, 0.55, 0.12), Vector3(0, -0.22, 0), hide)

	var legl := Node3D.new()
	legl.name = "LegL"
	legl.position = Vector3(-0.12, -0.1, 0)
	pelvis.add_child(legl)
	_part(legl, "Mesh", Vector3(0.14, 0.7, 0.14), Vector3(0, -0.35, 0), hide)

	var legr := Node3D.new()
	legr.name = "LegR"
	legr.position = Vector3(0.12, -0.1, 0)
	pelvis.add_child(legr)
	_part(legr, "Mesh", Vector3(0.14, 0.7, 0.14), Vector3(0, -0.35, 0), hide)


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

	var snarl := _anim("snarl", 1.2, true)
	_track(snarl, "Rig/Pelvis/Torso/Head/Jaw:rotation_degrees", [[0.0, Vector3.ZERO], [0.35, Vector3(18, 0, 0)], [0.7, Vector3.ZERO], [1.2, Vector3(12, 0, 0)]])
	_track(snarl, "Rig/Pelvis/Torso/Head:rotation_degrees", [[0.0, Vector3.ZERO], [0.6, Vector3(0, 8, 0)], [1.2, Vector3.ZERO]])
	lib.add_animation("snarl", snarl)

	var move := _anim("move", 0.55, true)
	_track(move, "Rig/Pelvis/LegL:rotation_degrees", [[0.0, Vector3(22, 0, 0)], [0.28, Vector3(-22, 0, 0)], [0.55, Vector3(22, 0, 0)]])
	_track(move, "Rig/Pelvis/LegR:rotation_degrees", [[0.0, Vector3(-22, 0, 0)], [0.28, Vector3(22, 0, 0)], [0.55, Vector3(-22, 0, 0)]])
	_track(move, "Rig/Pelvis/Torso/ArmL:rotation_degrees", [[0.0, Vector3(-18, 0, 0)], [0.28, Vector3(18, 0, 0)], [0.55, Vector3(-18, 0, 0)]])
	_track(move, "Rig/Pelvis/Torso/ArmR:rotation_degrees", [[0.0, Vector3(18, 0, 0)], [0.28, Vector3(-18, 0, 0)], [0.55, Vector3(18, 0, 0)]])
	_track(move, "Rig/Pelvis:position", [[0.0, Vector3(0, 0.95, 0)], [0.28, Vector3(0, 1.02, 0)], [0.55, Vector3(0, 0.95, 0)]])
	lib.add_animation("move", move)

	var attack := _anim("attack", 0.55, false)
	_track(attack, "Rig/Pelvis/Torso/ArmL:rotation_degrees", [[0.0, Vector3(-80, 0, 0)], [0.22, Vector3(50, 0, 15)], [0.55, Vector3.ZERO]])
	_track(attack, "Rig/Pelvis/Torso/ArmR:rotation_degrees", [[0.0, Vector3(-80, 0, 0)], [0.22, Vector3(50, 0, -15)], [0.55, Vector3.ZERO]])
	_track(attack, "Rig/Pelvis/Torso:position", [[0.0, Vector3(0, 0.28, 0)], [0.22, Vector3(0, 0.28, 0.18)], [0.55, Vector3(0, 0.28, 0)]])
	_track(attack, "Rig/Pelvis/Torso/Head/Jaw:rotation_degrees", [[0.0, Vector3.ZERO], [0.2, Vector3(28, 0, 0)], [0.55, Vector3.ZERO]])
	lib.add_animation("attack", attack)

	var death := _anim("death", 1.1, false)
	_track(death, "Rig:rotation_degrees", [[0.0, Vector3.ZERO], [0.7, Vector3(82, 0, 12)]])
	_track(death, "Rig:position", [[0.0, Vector3.ZERO], [0.7, Vector3(0, 0.15, 0.4)]])
	lib.add_animation("death", death)

	_ap.add_animation_library("", lib)
