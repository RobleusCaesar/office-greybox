extends Node3D
## Office loop: window sting, soft win at the money shot, death wrap.

const WIN_HOLD := 1.55

@onready var _player: CharacterBody3D = $Player
@onready var _window_light: OmniLight3D = $Lights/WindowLight

var _sting_done: bool = false
var _win_armed: bool = false
var _win_shown: bool = false
var _in_win: bool = false
var _win_time: float = 0.0
var _base_window_energy: float = 8.8
var _sting_boost: float = 0.0

var _death_ui: Control
var _win_ui: Control
var _sting_player: AudioStreamPlayer
var _distant_screech: AudioStreamPlayer
var _distant_growl: AudioStreamPlayer
var _distant_wait: float = 0.0
var _distant_toggle: bool = false
var _dressing
var _far_applied: bool = false


func _ready() -> void:
	_dressing = load("res://scripts/dressing.gd").new()
	_dressing.apply_near(self)
	_build_overlays()
	_sting_player = AudioStreamPlayer.new()
	_sting_player.stream = load("res://audio/window_sting.wav")
	_sting_player.volume_db = -3.0
	add_child(_sting_player)
	_setup_haunt_bed()
	_setup_distant_beds()
	if _player:
		_player.died.connect(_on_player_died)
	if _window_light:
		_base_window_energy = _window_light.light_energy
	call_deferred("_dress_after_first_frame")


func _dress_after_first_frame() -> void:
	# First closet frame paints, then far Meshy (CEO, couches, bath, elevator, ember).
	await get_tree().process_frame
	_apply_far_world()


func _apply_far_world() -> void:
	if _far_applied:
		return
	_far_applied = true
	if _dressing == null:
		_dressing = load("res://scripts/dressing.gd").new()
	_dressing.apply_far(self)
	_spawn_demon()


func _process(delta: float) -> void:
	_tick_distant_beds(delta)
	_maybe_sting()
	if _sting_boost > 0.0 and _window_light:
		_sting_boost = maxf(0.0, _sting_boost - delta * 6.0)
		_window_light.light_energy = _base_window_energy + _sting_boost
	if _win_shown or _player == null or _player.dead:
		return
	_in_win = _player_at_window()
	if _in_win:
		_win_time += delta
		if _win_time >= WIN_HOLD and not _win_armed:
			_show_win()
	else:
		_win_time = 0.0


func _setup_haunt_bed() -> void:
	# HTML5 packed-res probes often miss remapped audio. load() follows the remap.
	var stream: AudioStream = load("res://audio/under_broken_steel.mp3")
	if stream == null:
		stream = load("res://audio/haunt_bed.wav")
	if stream == null:
		return
	stream = stream.duplicate()
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = wav.data.size() / 2
	var bed := AudioStreamPlayer.new()
	bed.name = "HauntBed"
	bed.stream = stream
	bed.volume_db = -9.0
	bed.bus = "Master"
	bed.process_mode = Node.PROCESS_MODE_ALWAYS
	bed.autoplay = false
	add_child(bed)
	bed.play()


func _setup_distant_beds() -> void:
	# Occasional distant one-shots — quieter than HauntBed (−9 dB), never stacked on it.
	# load() only; packed-res FileAccess probes lie on HTML5.
	_distant_screech = _make_distant("DistantScreech", load("res://audio/monster_screech_distant.wav"))
	_distant_growl = _make_distant("DistantGrowl", load("res://audio/deamon_growl_distant.mp3"))
	_distant_wait = randf_range(9.0, 16.0)


func _make_distant(p_name: String, stream: AudioStream) -> AudioStreamPlayer:
	if stream == null:
		return null
	var p := AudioStreamPlayer.new()
	p.name = p_name
	p.stream = stream
	p.volume_db = -20.0
	p.bus = "Master"
	p.autoplay = false
	add_child(p)
	return p


func _tick_distant_beds(delta: float) -> void:
	_distant_wait -= delta
	if _distant_wait > 0.0:
		return
	_distant_wait = randf_range(16.0, 30.0)
	if (_distant_screech and _distant_screech.playing) or (_distant_growl and _distant_growl.playing):
		return
	var pick := _distant_growl if _distant_toggle else _distant_screech
	_distant_toggle = not _distant_toggle
	if pick and pick.stream:
		pick.play()


func _player_at_window() -> bool:
	var p := _player.global_position
	# Just inside the glass, centered on the three panes.
	return p.x > 35.6 and p.x < 38.0 and p.z > 9.2 and p.z < 13.8 and p.y < 2.5


func _maybe_sting() -> void:
	if _sting_done or _player == null:
		return
	if _player.global_position.x < 26.4:
		return
	var cam: Camera3D = _player.get_look_camera()
	if cam == null:
		return
	var facing := -cam.global_transform.basis.z
	if facing.dot(Vector3.RIGHT) > 0.72:
		_sting_done = true
		_sting_boost = 10.0
		if _sting_player:
			_sting_player.play()


func _on_player_died() -> void:
	_death_ui.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _show_win() -> void:
	_win_armed = true
	_win_shown = true
	_win_ui.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if _player:
		_player.input_locked = true


func _retry() -> void:
	get_tree().reload_current_scene()


func _menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/title.tscn")


func _keep_walking() -> void:
	_win_ui.visible = false
	if _player:
		_player.input_locked = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _spawn_demon() -> void:
	var packed: PackedScene = load("res://scenes/demon.tscn")
	var s1 := get_node_or_null("DemonSpots/DemonSpot_01") as Node3D
	if packed and s1:
		var d1: CharacterBody3D = packed.instantiate()
		d1.name = "Demon_01"
		d1.max_hp = 120.0
		d1.move_speed = 3.15
		d1.attack_damage = 18.0
		d1.attack_range = 1.5
		d1.aggro_range = 6.8
		d1.position = s1.global_position
		add_child(d1)
	# Ember Demon — second live enemy. Do not spawn Demon_02 at the CEO door.
	_spawn_ember()


func _spawn_ember() -> void:
	var ember_ps: PackedScene = load("res://scenes/ember.tscn")
	var s_rec := get_node_or_null("DemonSpots/DemonSpot_Reception") as Node3D
	if ember_ps == null:
		return
	var enemy: CharacterBody3D = ember_ps.instantiate()
	enemy.name = "Ember_01"
	enemy.max_hp = 120.0
	if s_rec:
		enemy.position = s_rec.global_position
	else:
		enemy.position = Vector3(21.55, 0.0, 11.55)
	enemy.rotation_degrees = Vector3(0, -90, 0)
	add_child(enemy)
	enemy.scale = Vector3(1.30, 1.30, 1.30)


func _style_title(lab: Label, size: int, color: Color) -> void:
	lab.add_theme_font_size_override("font_size", size)
	lab.add_theme_color_override("font_color", color)
	lab.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	lab.add_theme_constant_override("shadow_offset_x", 2)
	lab.add_theme_constant_override("shadow_offset_y", 2)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _btn(text: String, parent: Control) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(220, 44)
	b.add_theme_font_size_override("font_size", 18)
	parent.add_child(b)
	return b


func _build_overlays() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)

	_death_ui = _card(layer, "You died")
	var retry := _btn("Retry", _death_ui.get_node("Box"))
	retry.pressed.connect(_retry)
	var menu_d := _btn("Menu", _death_ui.get_node("Box"))
	menu_d.pressed.connect(_menu)
	_death_ui.visible = false

	_win_ui = _card(layer, "HELLFALL")
	var sub := Label.new()
	sub.text = "Denver is burning."
	_style_title(sub, 18, Color(0.82, 0.55, 0.32, 0.95))
	_win_ui.get_node("Box").add_child(sub)
	var keep := _btn("Keep walking", _win_ui.get_node("Box"))
	keep.pressed.connect(_keep_walking)
	var menu_w := _btn("Menu", _win_ui.get_node("Box"))
	menu_w.pressed.connect(_menu)
	_win_ui.visible = false


func _card(layer: CanvasLayer, title: String) -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(root)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.02, 0.025, 0.72)
	root.add_child(dim)
	var box := VBoxContainer.new()
	box.name = "Box"
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-160, -110)
	box.size = Vector2(320, 240)
	box.add_theme_constant_override("separation", 14)
	root.add_child(box)
	var lab := Label.new()
	lab.text = title
	_style_title(lab, 36, Color(0.93, 0.90, 0.84))
	box.add_child(lab)
	return root
