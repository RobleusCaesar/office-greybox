extends CharacterBody3D
## Simple chase / telegraph / attack demon. Killable. Collision does not use the window.

enum State { IDLE, CHASE, TELEGRAPH, RECOVER, DEAD }

@export var max_hp: float = 80.0
@export var move_speed: float = 3.3
@export var attack_damage: float = 16.0
@export var attack_range: float = 1.55
@export var aggro_range: float = 8.0
@export var telegraph_time: float = 0.55
@export var recover_time: float = 0.7
@export var body_scale: float = 1.0

var hp: float = 80.0
var state: State = State.IDLE

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _timer: float = 0.0
var _body: Node3D
var _mat: StandardMaterial3D
var _snd: AudioStreamPlayer3D
var _dead: bool = false


func _ready() -> void:
	hp = max_hp
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("enemies")
	_build_mesh()
	_snd = AudioStreamPlayer3D.new()
	_snd.stream = load("res://audio/demon_growl.wav")
	_snd.volume_db = -2.0
	_snd.max_distance = 18.0
	add_child(_snd)


func take_damage(amount: float) -> void:
	if _dead:
		return
	hp -= amount
	if _mat:
		_mat.emission_energy_multiplier = 3.2
	if hp <= 0.0:
		_die()
		return
	if state == State.IDLE:
		state = State.CHASE


func _die() -> void:
	_dead = true
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	velocity = Vector3.ZERO
	if _body:
		var tw := create_tween()
		tw.tween_property(_body, "scale", Vector3(body_scale * 1.1, 0.08, body_scale * 1.1), 0.28)
		tw.tween_callback(queue_free)
	else:
		queue_free()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if _dead:
		move_and_slide()
		return

	if _mat:
		_mat.emission_energy_multiplier = move_toward(_mat.emission_energy_multiplier, 0.7, delta * 4.0)

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
			if dist <= aggro_range:
				state = State.CHASE
				if _snd:
					_snd.play()
		State.CHASE:
			if dir != Vector3.ZERO:
				look_at(global_position + dir, Vector3.UP)
			if dist <= attack_range:
				state = State.TELEGRAPH
				_timer = telegraph_time
				velocity.x = 0.0
				velocity.z = 0.0
				if _mat:
					_mat.emission = Color(1.0, 0.15, 0.05)
					_mat.emission_energy_multiplier = 4.5
				if _body:
					_body.scale = Vector3(body_scale * 1.08, body_scale * 1.18, body_scale * 1.08)
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
				if _body:
					_body.scale = Vector3(body_scale, body_scale, body_scale)
		State.RECOVER:
			_timer -= delta
			velocity.x = 0.0
			velocity.z = 0.0
			if _timer <= 0.0:
				state = State.CHASE

	move_and_slide()


func _build_mesh() -> void:
	_body = Node3D.new()
	_body.name = "Body"
	_body.scale = Vector3(body_scale, body_scale, body_scale)
	add_child(_body)
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = Color(0.22, 0.05, 0.05)
	_mat.emission_enabled = true
	_mat.emission = Color(0.55, 0.08, 0.04)
	_mat.emission_energy_multiplier = 0.7
	_mat.roughness = 0.7
	_part(Vector3(0.55, 1.15, 0.38), Vector3(0.0, 0.95, 0.0))
	_part(Vector3(0.42, 0.38, 0.32), Vector3(0.0, 1.68, 0.04))
	_part(Vector3(0.08, 0.32, 0.08), Vector3(-0.14, 1.95, 0.0), Color(0.12, 0.04, 0.04))
	_part(Vector3(0.08, 0.32, 0.08), Vector3(0.14, 1.95, 0.0), Color(0.12, 0.04, 0.04))
	_part(Vector3(0.10, 0.08, 0.10), Vector3(-0.10, 1.72, 0.18), Color(0.9, 0.2, 0.05), 2.4)
	_part(Vector3(0.10, 0.08, 0.10), Vector3(0.10, 1.72, 0.18), Color(0.9, 0.2, 0.05), 2.4)
	_part(Vector3(0.16, 0.55, 0.16), Vector3(-0.28, 0.95, 0.05))
	_part(Vector3(0.16, 0.55, 0.16), Vector3(0.28, 0.95, 0.05))


func _part(size: Vector3, pos: Vector3, color: Color = Color.BLACK, emit: float = -1.0) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	if color == Color.BLACK:
		mi.material_override = _mat
	else:
		var m := StandardMaterial3D.new()
		m.albedo_color = color
		m.emission_enabled = emit > 0.0
		if emit > 0.0:
			m.emission = color
			m.emission_energy_multiplier = emit
		mi.material_override = m
	_body.add_child(mi)
