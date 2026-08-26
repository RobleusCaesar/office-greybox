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


func _ready() -> void:
	_dress_window()
	_spawn_demons()
	_build_overlays()
	_sting_player = AudioStreamPlayer.new()
	_sting_player.stream = load("res://audio/window_sting.wav")
	_sting_player.volume_db = -3.0
	add_child(_sting_player)
	if _player:
		_player.died.connect(_on_player_died)
	if _window_light:
		_base_window_energy = _window_light.light_energy


func _process(delta: float) -> void:
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


func _dress_window() -> void:
	var win := get_node_or_null("FutureAssetSlots/CEOOffice/MoneyShotWindow")
	if win == null:
		return
	var pane_mats := [
		load("res://materials/mat_window_p1.tres"),
		load("res://materials/mat_window_p2.tres"),
		load("res://materials/mat_window_p3.tres"),
	]
	var names := ["Pane_01", "Pane_02", "Pane_03"]
	for i in 3:
		var pane := win.get_node_or_null(names[i]) as CSGBox3D
		if pane:
			pane.material = pane_mats[i]
	var metal: Material = load("res://materials/mat_mullion.tres")
	for n in ["Mullion_Left", "Mullion_01", "Mullion_02", "Mullion_Right", "Sill", "Head"]:
		var node := win.get_node_or_null(n) as CSGBox3D
		if node:
			node.material = metal
	var glass_m := get_node_or_null("FutureAssetSlots/EastHall/DeadOfficeGlassMullion") as CSGBox3D
	if glass_m:
		glass_m.material = metal
	var sill := get_node_or_null("FutureAssetSlots/EastHall/DeadOfficeGlassSill") as CSGBox3D
	if sill:
		sill.material = metal


func _spawn_demons() -> void:
	var packed: PackedScene = load("res://scenes/demon.tscn")
	var s1 := get_node_or_null("DemonSpots/DemonSpot_01") as Node3D
	var s2 := get_node_or_null("DemonSpots/DemonSpot_02") as Node3D
	if s1:
		var d1: CharacterBody3D = packed.instantiate()
		d1.name = "Demon_01"
		d1.max_hp = 80.0
		d1.move_speed = 3.45
		d1.attack_damage = 16.0
		d1.attack_range = 1.5
		d1.aggro_range = 6.5
		d1.telegraph_time = 0.48
		d1.body_scale = 0.95
		d1.position = s1.global_position
		add_child(d1)
	if s2:
		var d2: CharacterBody3D = packed.instantiate()
		d2.name = "Demon_02"
		d2.max_hp = 140.0
		d2.move_speed = 2.7
		d2.attack_damage = 26.0
		d2.attack_range = 1.75
		d2.aggro_range = 9.5
		d2.telegraph_time = 0.62
		d2.body_scale = 1.35
		d2.position = s2.global_position
		add_child(d2)


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

	_win_ui = _card(layer, "THE WINDOW")
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
